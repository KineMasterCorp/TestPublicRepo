//
//  HTTPFileLoader.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import Foundation

protocol HTTPFileLoaderDelegate: AnyObject {
    func didReceive(response: URLResponse, on dataTask: URLSessionDataTask)
    func didReceive(data: Data, on dataTask: URLSessionDataTask)
    func didComplete(with error: Error?, on dataTask: URLSessionDataTask)
}

class HTTPFileLoader: NSObject {
    var session: URLSession!
    weak var delegate: HTTPFileLoaderDelegate?

    override init() {
        super.init()
        
        session = createURLSession()
    }
    
    deinit {
        print("HTTPLoader deinit called")
    }
    
    private func createURLSession() -> URLSession {
        let config = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
    }
    
    func prepareLoadingTask(url: URL, offset: Int, length: Int? = nil) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        if let length = length {
            let endOffset = offset + Int(length) - 1
            request.addValue("bytes=\(offset)-\(endOffset)", forHTTPHeaderField: "Range")
        } else if offset > 0 {
            request.addValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        }

        print("load -> headers: \(request.allHTTPHeaderFields ?? ["":""])")
        
        return session.dataTask(with: request)
    }

    func startLoading(using task: URLSessionDataTask) {
        task.resume()
    }
    
    func cancel(url: URL) {
        
    }
}

// MARK: - URLSessionDataDelegate
extension HTTPFileLoader: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
        delegate?.didReceive(response: response, on: dataTask)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        delegate?.didReceive(data: data, on: dataTask)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError: Error?) {
        guard let dataTask = task as? URLSessionDataTask else {
            NSLog("Couldn't convert URLSessionTask to URLSessionDataTask!")
            return
        }
        delegate?.didComplete(with: didCompleteWithError, on: dataTask)
    }
}


