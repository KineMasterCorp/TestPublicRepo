//
//  FeedDataRequest.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/30.
//

import Foundation

enum FeedQueryType {
    case category, tag
}

struct FeedDataRequest {
    let target: String
    let type: FeedQueryType
    
    init (target: String, type: FeedQueryType) {
        self.target = target
        self.type = type
    }
}
