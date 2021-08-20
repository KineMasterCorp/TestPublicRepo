//
//  VideoLoader.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/18.
//

import AVFoundation

class VideoLoader: NSObject {
    private let urlSchemePrefix: String
    private let httpLoader: HTTPLoader
    private var videoCache: VideoCache
    private var loadingRequests = [AVAssetResourceLoadingRequest]()
    private var downloadLogTick: UInt64 = 0

    init(urlSchemePrefix: String, videoCache: VideoCache? = nil) {
        self.urlSchemePrefix = urlSchemePrefix
        httpLoader = HTTPLoader()
        self.videoCache = videoCache ?? VideoCache(capacity: 20)
        
        super.init()
        httpLoader.delegate = self
    }
    
    func load(url: URL, length: Int? = nil) {   // Load called for the file that has highest priority.
        
        var cachedSize = 0
        var contentLength: Int64 = 0
        
        if let videoInfo = videoCache.cache(for: url) {
            cachedSize = videoInfo.data.count
            contentLength = videoInfo.contentLength
        }
        
        let loaded = checkLoaded(length: length, cachedSize: cachedSize, contentLength: contentLength)
        
        NSLog("[VideoLoader] load: url: \(url.lastPathComponent), length: \(length ?? -1), loaded: \(loaded), cached: \(cachedSize), contentLength: \(contentLength )")
        
        guard !loaded else { return }
        
        let newLength = length == nil ? nil : length! - cachedSize

        httpLoader.load(url: url, offset: cachedSize, length: newLength)   // load the remaining file except the cached data.
    }

    func cancelLoading(except url: URL? = nil) {
        NSLog("[VideoLoader] cancelLoading except url: \(url?.lastPathComponent ?? "nil")")
        httpLoader.cancelAllRequests(except: url)
    }
    
    private func checkLoaded(length: Int?, cachedSize: Int, contentLength: Int64) -> Bool {
        var loaded = false
        
        guard contentLength > 0 else {
            return loaded
        }

        if let length = length, length <= cachedSize {
            loaded = true
        } else if cachedSize >= contentLength {
            loaded = true
        }
        return loaded
    }
    
    private func getVideoURL(from fakeURL: URL?) -> URL? {
        guard let videoURLString = fakeURL?.absoluteString.replacingOccurrences(of: urlSchemePrefix, with: "") else { return nil }
        return URL(string: videoURLString)
    }
    
    private func checkRespond(to request: AVAssetResourceLoadingRequest, from videoInfo: VideoInfo) -> Bool {
        guard let url = getVideoURL(from: request.request.url),
              let dataRequest = request.dataRequest else {
            return false
        }
        let response = videoInfo.response
        let requestCurrentOffset = Int(dataRequest.currentOffset)
        let requestedOffset = Int(dataRequest.requestedOffset)
        let requestLength = dataRequest.requestedLength - (requestCurrentOffset - requestedOffset)
        
        guard requestLength > 0,
              let data = videoInfo.getData(from: requestCurrentOffset, length: requestLength) else {
            return false
        }
        let contentLength = videoInfo.contentLength
        
        if request.contentInformationRequest != nil {
            request.contentInformationRequest?.isByteRangeAccessSupported = true
            request.contentInformationRequest?.contentType = response.mimeType
            request.contentInformationRequest?.contentLength = contentLength
            
            NSLog("[VideoLoader] checkRespond[\(url.lastPathComponent)] content-length: \(contentLength), mimeType: \(response.mimeType ?? "")")
        }
        
        dataRequest.respond(with: data)
        
        let readLength = dataRequest.currentOffset + Int64(data.count)
        let readPercent = Int(Float(readLength) / Float(contentLength) * 100)
        
        NSLog("[VideoLoader] checkRespond return: \(data.count) / \(requestLength), read: \(readLength) / \(contentLength) (\(readPercent)%%)")

        if data.count >= requestLength {
            let cachedSize = videoInfo.data.count
            NSLog("[VideoLoader] checkRespond completed[\(url.lastPathComponent)] req(o: \(requestedOffset), l: \(dataRequest.requestedLength), co: \(requestCurrentOffset)), requestRemain: \(requestLength), return \(data.count). cached: \(cachedSize)")
            request.finishLoading()
            return true
        }

        return false
    }
    
    private func checkRespond(to url: URL, from videoInfo: VideoInfo) {
        let requests = loadingRequests.filter { getVideoURL(from: $0.request.url) == url }
        guard !requests.isEmpty else { return }
        
        var completedRequests = Set<AVAssetResourceLoadingRequest>()
        for request in requests {
            if checkRespond(to: request, from: videoInfo) {
                completedRequests.insert(request)
            }
        }
        if !completedRequests.isEmpty {
            loadingRequests = loadingRequests.filter { !completedRequests.contains($0) }
        }
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension VideoLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let dataRequest = loadingRequest.dataRequest,
              let videoURL = getVideoURL(from: loadingRequest.request.url) else {
            NSLog("[VideoLoader] resourceLoader invalid param! dataRequest: \(loadingRequest.dataRequest == nil ? "nil" : "ok"), url: \(loadingRequest.request.url?.absoluteString ?? "")")
            return false
        }
        NSLog("[VideoLoader] resourceLoader url: \(videoURL.lastPathComponent), o: \(dataRequest.requestedOffset), l: \(dataRequest.requestedLength), co: \(dataRequest.currentOffset)")
        
        if let videoInfo = videoCache.cache(for: videoURL), checkRespond(to: loadingRequest, from: videoInfo) {   // Already cached.
            return true
        }
        loadingRequests.append(loadingRequest)

//        load(url: videoURL)

        return true
    }

//    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
//        NSLog("[VideoLoader] resourceLoader didCancel url: \(loadingRequest.request.url?.lastPathComponent ?? "nil"), o: \(loadingRequest.dataRequest?.requestedOffset ?? -1), l: \(loadingRequest.dataRequest?.requestedLength ?? -1)")
//    }
}

extension VideoLoader: HTTPLoaderDelegate {
    func didRecvResponse(url: URL, response: URLResponse) {
//        NSLog("[VideoLoader] didRecvResponse url: \(url.lastPathComponent), response: \(response)")
        if let videoInfo = videoCache.cache(for: url) {
            NSLog("[VideoLoader] already cached \(String(describing: videoInfo.response.url))")
        } else {
            videoCache.set(for: url, with: response)
            NSLog("[VideoLoader] didRecvResponse url: \(url.lastPathComponent), response: \(response)")
        }
        
        downloadLogTick = 0
    }

    func didRecvData(url: URL, data: Data, offset: Int) {
        if let videoInfo = videoCache.cache(for: url) {
            videoInfo.store(data: data, offset: offset)
            let now = DispatchTime.now().uptimeNanoseconds
            let logInterval: UInt64 = 1000000000
            if now > downloadLogTick + logInterval {
                downloadLogTick = now
                let cached = videoInfo.data.count
                NSLog("[VideoLoader] didRecvData url: \(url.lastPathComponent), offset: \(offset), recv: \(data.count), cached: \(cached)")
            }
            checkRespond(to: url, from: videoInfo)
        }
    }

    func didComplete(url: URL, error: Error?) {        
        if let videoInfo = videoCache.cache(for: url) {
            let cached = videoInfo.data.count
            NSLog("[VideoLoader] didComplete url: \(url.lastPathComponent), cached: \(cached), error: \(error?.localizedDescription ?? "none")")
        }
    }
}
