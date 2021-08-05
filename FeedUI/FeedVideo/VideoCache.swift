//
//  VideoCache.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import Foundation

private class VideoInfo {
    private(set) var data = Data()
    private(set) var offset = 0
    private(set) var response: URLResponse
    private(set) var contentLength: Int64 = 0

    init(response: URLResponse) {
        self.response = response
        contentLength = 0
        if let contentRange = response.valueForHeaderField("content-range") {
            let components = contentRange.components(separatedBy: "/")
            if components.count == 2 {
                if let string = components.last,
                   let length = Int64(string){
                    contentLength = length
                }
            }
        }
        
        if contentLength == 0 {
            contentLength = response.expectedContentLength
        }
        
        NSLog("VideoInfo[\(response.url?.lastPathComponent ?? "")] ContentLength: \(contentLength)")
    }

    func store(data newData: Data, offset newOffset: Int) {
        // The data range should be overwrapped to merge. Otherwise, the data will be dropped.
        let downloadedEndOffset = offset + data.count
        guard newOffset <= downloadedEndOffset,
              newOffset + newData.count >= downloadedEndOffset else {
            NSLog("mergeData: drop non-overwrapping data. org(\(offset) ~ \(data.count)), new(\(newOffset) ~ \(newData.count))")
            return
        }
        let removeCount = Int(downloadedEndOffset - newOffset)
        let newRange = (removeCount..<newData.count)
        data.append(newData.subdata(in: newRange))
        
//        NSLog("mergeData: org(\(offset) ~ \(downloadedEndOffset)), new(\(newOffset) ~ \(newData.count)), afterMerge(\(data.count))")
    }

    func getData(from offset: Int, length: Int?) -> Data? {
        guard offset < self.offset + Int(data.count) else {
            return nil
        }
        
        var returnLength = self.offset + Int(data.count) - offset
        if let requestLength = length, returnLength > requestLength {
            returnLength = requestLength
        }

        return data.subdata(in: offset..<offset+returnLength)
    }
    
    private func getContentLength(from response: URLResponse) {
        
    }
}

class VideoCache {
    private var cache = NSCache<NSString, VideoInfo>()
    
    func prepare(for url: URL, with response: URLResponse) {
        if cache.object(forKey: NSString(string: url.absoluteString)) != nil { return }
        let videoInfo = VideoInfo(response: response)
        cache.setObject(videoInfo, forKey: NSString(string: url.absoluteString))
    }
    
    func getResponse(for url: URL) -> URLResponse? {
        guard let videoInfo = cache.object(forKey: NSString(string: url.absoluteString)) else { return nil }
        return videoInfo.response
    }
    
    func getContentLength(for url: URL) -> Int64? {
        guard let videoInfo = cache.object(forKey: NSString(string: url.absoluteString)) else { return nil }
        return videoInfo.contentLength
    }

    func getData(for url: URL, offset: Int, length: Int?) -> Data? {
        guard let videoInfo = cache.object(forKey: NSString(string: url.absoluteString)) else { return nil }
        return videoInfo.getData(from: offset, length: length)
    }
    
    func storeData(for url: URL, data: Data, offset: Int) {
        guard let videoInfo = cache.object(forKey: NSString(string: url.absoluteString)) else { return }
        videoInfo.store(data: data, offset: offset)
    }
    
    func getDataLength(for url: URL) -> Int {
        guard let videoInfo = cache.object(forKey: NSString(string: url.absoluteString)) else { return 0 }
        return videoInfo.data.count
    }
    
    func isCompleted(for url: URL) -> (Bool, Error?) {
        return (true, nil)
    }
}

public extension URLResponse {
    func valueForHeaderField(_ headerField: String) -> String? {
        guard let response = self as? HTTPURLResponse else { return nil }
        if #available(iOS 13.0, *) {
            return response.value(forHTTPHeaderField: headerField)
        } else {
            return (response.allHeaderFields as NSDictionary)[headerField] as? String
        }
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
