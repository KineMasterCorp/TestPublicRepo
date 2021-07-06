//
//  HTTPLoader.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/15.
//

import Foundation


protocol HTTPLoaderDelegate: AnyObject {
    func didRecvResponse(url: URL, response: URLResponse)
    func didRecvData(url: URL, data: Data, offset: Int)
    func didComplete(url: URL, error: Error?)
}

class HTTPLoader {
    weak var delegate: HTTPLoaderDelegate?

    private var requests = [HTTPRequest]()
    private let loader = HTTPFileLoader()

    init() {
        loader.delegate = self
    }

    func load(url: URL, offset: Int = 0, length: Int? = nil) {
        removeCompletedRequests()
        
        if let newRange = calcDownloadRange(url: url, offset: offset, length: length) {
            let request = HTTPRequest(url: url, offset: newRange.0, length: newRange.1, priority: 0, loader: loader)
            request.delegate = delegate
            requests.append(request)
    
            NSLog("HTTPLoader.load: New request for \(url.lastPathComponent), o: \(newRange.0), l: \(newRange.1 ?? -1)")
        } else {
            NSLog("HTTPLoader.load: Request already exist. url:\(url.lastPathComponent), o: \(offset), l: \(length ?? -1)")
            return
        }

        if let request = checkDownloadNext() {
            request.load()
        }
    }
    
    func cancelAllRequests(except url: URL? = nil) {
        NSLog("cancelAllRequests: count: \(requests.count)")
        var canceledRequests = Set<HTTPRequest>()
        requests.forEach { request in
            if request.url != url {
                request.cancel()
                canceledRequests.insert(request)
            }
        }
    }
    
    private func getRequest(byURL url: URL) -> HTTPRequest? {
        return requests.first { $0.url == url }
    }
    private func getRequest(byTask task: URLSessionDataTask) -> HTTPRequest? {
        return requests.first { $0.task == task }
    }
    private func calcDownloadRange(url: URL, offset: Int, length: Int?) -> (Int, Int?)? {
        let requests = requests.filter({ $0.url == url })
        var newOffset = offset
        var newLength = length

        for request in requests {
            // Extract overwrapped range this is contained in the previous request.
            if let newRange = request.calcDownloadRange(for: newOffset, length: newLength) {
                newOffset = newRange.0
                newLength = newRange.1
            } else {
                return nil  // This range is contained in the previous request.
            }
        }
        return (newOffset, newLength)
    }
    private func checkDownloadNext() -> HTTPRequest? {
        return requests.first { $0.state == .none }
    }
    
    private func removeCompletedRequests() {
        var completedRequests = Set<HTTPRequest>()
        requests.forEach {
            if $0.state == .completed {
                completedRequests.insert($0)
            }
        }
        requests = requests.filter { !completedRequests.contains($0) }
    }
}

extension HTTPLoader: HTTPFileLoaderDelegate {
    func didReceive(response: URLResponse, on dataTask: URLSessionDataTask) {
        guard let request = getRequest(byTask: dataTask) else {
            NSLog("didReceive(response): Couldn't find matching request. task: \(dataTask)")
            return
        }
        request.didReceive(response: response)
    }
    
    func didReceive(data: Data, on dataTask: URLSessionDataTask) {
        guard let request = getRequest(byTask: dataTask) else {
            NSLog("didReceive(data): \(data.count) bytes. Couldn't find matching request.")
            return
        }
        request.didReceive(data: data)
    }
    
    func didComplete(with error: Error?, on dataTask: URLSessionDataTask) {
        guard let request = getRequest(byTask: dataTask) else {
            NSLog("didComplete: Couldn't find matching request. error: \(error?.localizedDescription ?? "none")")
            return
        }
        request.didComplete(error: error)
    }
}
