//
//  HTTPFileLoader.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import Foundation

typealias DataHandler = (Data, Bool) -> Void

protocol HTTPFileLoaderDelegate: AnyObject {
    func startLoading(for url: URL, offset: UInt64?, length: UInt64?, dataTask: URLSessionDataTask)
    func didRecvData(dataTask: URLSessionDataTask, data: Data)
    func complete(dataTask: URLSessionDataTask)
}

class HTTPFileLoader: NSObject {
    var session: URLSession!
    var requests = RequestManager()
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
        operationQueue.maxConcurrentOperationCount = 2
        return URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
    }

    func load(url: URL, offset: UInt64? = nil, length: UInt64? = nil) {
        var request = URLRequest(url: url)
        if let offset = offset {
            if let length = length {
                let endOffset = offset + length - 1
                request.addValue("bytes=\(offset)-\(endOffset)", forHTTPHeaderField: "Range")
            } else {
                request.addValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
            }
        }
        
        print("load -> headers: \(request.allHTTPHeaderFields ?? ["":""])")

        let task = session.dataTask(with: request)
//        requests.add(url: url, task: task, range: range, dataHandler: handler)
        task.resume()
    }
    
    func cancel(url: URL) {
        
    }
}

// MARK: - URLSessionDataDelegate
extension HTTPFileLoader: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
        print("didReceive response: \(response)")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceive data: \(data)")
        delegate?.didRecvData(dataTask: dataTask, data: data)
    }
}
