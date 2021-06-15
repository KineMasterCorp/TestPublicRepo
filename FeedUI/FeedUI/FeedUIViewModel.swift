//
//  FeedUIViewModel.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import Foundation

class FeedUIViewModel {
    private var currentTag: String = "전체" {
        didSet {
            DispatchQueue.main.async {
                self.changedTag?()
            }
        }
    }
    
    private var allSources = FeedDataSource.allVideos()
    
    private(set) var filteredSources = FeedDataSource(videos: [FeedDataInfo]()) {
        didSet {
            DispatchQueue.main.async {
                self.reloaded?()
            }
        }
    }
    
    var fetched: (() -> Void)?
    var reloaded: (() -> Void)?
    var changedTag: (() -> Void)?
    
    private var isLoading: Bool = false
    
    var dataCount: Int {
        filteredSources.dataCount
    }
    
    func getDataInfo(of index: Int) -> FeedDataInfo? {
        return filteredSources.getDataInfo(of: index)
    }
    
    func getTags() -> [String] {
        var items = [String]()
        items.append("전체")
        items.append(contentsOf: allSources.videos.compactMap { video in video.category }.uniqued())
        return items        
    }
    
    func filter(by category: String = "전체") {
        filteredSources = FeedDataSource(videos: allSources.videos.filter({(video : FeedDataInfo) -> Bool in
            let doesCategoryMatch = (category == "전체") || (video.category == category)
            return doesCategoryMatch
        }))
        
        if currentTag != category {
            currentTag = category
        }
    }
    
    func filter(with searchText: String) {
        filteredSources = FeedDataSource(videos: allSources.videos.filter({(video : FeedDataInfo) -> Bool in
            let doesCategoryMatch = (currentTag == "전체") || (video.category == currentTag)
            if searchText.isEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && video.title.lowercased().contains(searchText.lowercased())
            }
        }))
    }
    
    func fetch(completion: @escaping (() -> Void)) {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global(qos: .userInteractive).async {
                let appendVideos = FeedDataSource.fetch().videos.filter {
                    !self.allSources.videos.contains($0)
                }

                if 0 < appendVideos.count {
                    self.allSources.append(contentsOf: appendVideos)
                    self.filter(by: self.currentTag)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.fetched?()
                        completion()
                    }
                } else {
                    self.isLoading = false
                    completion()
                }
            }
        }
    }
}
