//
//  HTTPLoader.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/15.
//

import Foundation


protocol HTTPLoaderDelegate: AnyObject {
    func didRecvData(url: URL, data: Data, offset: UInt64?)
    func didComplete(url: URL, error: NSError)
}

class HTTPLoader {
    weak var delegate: HTTPLoaderDelegate?
    func load(url: URL, offset: UInt64? = nil, length: UInt64? = nil) {
        
    }
}
