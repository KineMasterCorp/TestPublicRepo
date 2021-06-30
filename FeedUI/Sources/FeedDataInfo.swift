//
//  FeedDataInfo.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/30.
//

import Foundation

class FeedDataInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: FeedDataInfo, rhs: FeedDataInfo) -> Bool {
        lhs.title == rhs.title
    }
    
    let title: String
    let tags: [String]
    let videoURL: URL
    let poster: URL
    let category: String
    
    init(title: String, tags: [String], videoURL: URL, poster: String, category: String) {
        self.title = title
        self.tags = tags
        self.videoURL = videoURL
        self.poster = URL(string: poster)!
        self.category = category
    }
}
