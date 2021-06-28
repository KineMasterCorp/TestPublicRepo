//
//  RequestManager.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/22.
//

import Foundation


class RequestManager {
//    private var requests = [LoadingRequest]()
//    
//    private func getRequest(url: URL) -> LoadingRequest? {
//        return requests.first { $0.url == url }
//    }
//    private func getRequest(task: URLSessionDataTask) -> LoadingRequest? {
//        return requests.first { $0.task == task }
//    }
//    
//    func add(url: URL, task: URLSessionDataTask, range: HTTPRange? = nil, dataHandler: @escaping DataHandler) {
//        if let request = getRequest(url: url) {
//            request.add(range: range, dataHandler: dataHandler)
//            print("Add request to existing one. url: \(url.lastPathComponent), range: \(range?.offset ?? 0) ~ \(range?.length ?? 0)")
//        } else {
//            let request = LoadingRequest(url: url, task: task)
//            request.add(range: range, dataHandler: dataHandler)
//            requests.append(request)
//            print("Add new request. url: \(url.lastPathComponent), range: \(range?.offset ?? 0) ~ \(range?.length ?? 0)")
//        }
//    }
//    
//    func dataReceived(task: URLSessionDataTask, data: Data) {
//        guard let request = getRequest(task: task) else {
//            print("No matching task! data: \(data.count)")
//            return
//        }
//        
//        print("Data received \(data.count) for \(request.url)")
//    }
//    
//    func cancelAllPendingRequest() {
//        
//    }
}
