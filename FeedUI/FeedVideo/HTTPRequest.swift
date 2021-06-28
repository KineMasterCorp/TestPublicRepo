//
//  HTTPRequest.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import Foundation

// Request for 1 url.
class HTTPRequest {
    enum LoadingState: Int {
        case none = 0, loading, completed
    }

    var url: URL
    var requestOffset: UInt64?
    var requestLength: UInt64?
    var priority: Int

    var state = LoadingState.none
    private var task: URLSessionDataTask?

    private var data = Data()

    init(url: URL, offset: UInt64?, length: UInt64?, priority: Int) {
        self.url = url
        requestOffset = offset
        requestLength = length
        self.priority = priority
    }
    
    func merge(offset: UInt64? = nil, length: UInt64? = nil) -> Bool {
        return true
    }
}
