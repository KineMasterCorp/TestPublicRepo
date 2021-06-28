//
//  VideoLoader.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/18.
//

import AVFoundation

class VideoLoader: NSObject {
    private var urlSchemePrefix: String

    init(urlSchemePrefix: String) {
        self.urlSchemePrefix = urlSchemePrefix
    }
    func preload(url: URL) {
        let orgURL = url.absoluteString.replacingOccurrences(of: urlSchemePrefix, with: "")
        NSLog("preload input url: \(url.path), original url: \(orgURL)")
    }

    func cancelLoading(except url: URL) {
        NSLog("cancelLoading except url: \(url.lastPathComponent)")
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension VideoLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        NSLog("resourceLoader shouldWaitForLoadingOfRequestedResource url: \(loadingRequest.request.url?.lastPathComponent ?? "nil")")
        NSLog("resourceLoader shouldWaitForLoadingOfRequestedResource offset: \(loadingRequest.dataRequest?.requestedOffset ?? -1), length: \(loadingRequest.dataRequest?.requestedLength ?? -1)")
        
        
//        if self.urlSession == nil {
//            self.urlSession = self.createURLSession()
//            let task = self.urlSession!.dataTask(with: self.url)
//            task.resume()
//        }
//
//        self.loadingRequests.append(loadingRequest)
        
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        NSLog("resourceLoader didCancel url: \(loadingRequest.request.url?.lastPathComponent ?? "nil")")
        NSLog("resourceLoader didCancel offset: \(loadingRequest.dataRequest?.requestedOffset ?? -1), length: \(loadingRequest.dataRequest?.requestedLength ?? -1)")
//        if let index = self.loadingRequests.firstIndex(of: loadingRequest) {
//            self.loadingRequests.remove(at: index)
//        }
    }
}
