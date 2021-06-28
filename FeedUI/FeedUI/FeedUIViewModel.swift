//
//  FeedUIViewModel.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import Foundation
import AVFoundation

struct CategoryCellModel: Equatable {
    let category: String
}

struct FeedHeaderViewModel {
    @BindableObject var selectedCategory = ""
    var cellModels: [CategoryCellModel] = {[CategoryCellModel.init(category: "전체")]}()
    
    init (cellModels: [CategoryCellModel]) {
        self.cellModels.append(contentsOf: cellModels)
    }
}

struct ImageCellModel {    
    let title: String
    let url: URL!
    var height: CGFloat = CGFloat.random(in: 150...300)
    
    func load(completion: @escaping (UIImage?) -> Void) {
        ImageCache.publicCache.load(url: url as NSURL) { uiImage in
            if let validImage = uiImage {
                completion(validImage)
            } else {
                print("image load failed")
            }
        }
    }
}

class VideoCellModel {
    let title: String
    let tags: [String]
    let url: URL
    
    var asset: AVURLAsset?
    var loadState: LoadState = .none
    
    enum LoadState: Int {
        case none = 0, loading, loaded
    }
    
    init(title: String, tags: [String], url: URL) {
        self.title = title
        self.tags = tags
        self.url = url
    }
    
    func load() {
        if loadState == .none {
            asset = AVURLAsset(url: url)
            loadState = .loading
            let keys = ["playable","tracks","duration"]
            let loadStartTick = DispatchTime.now().uptimeNanoseconds
            asset?.loadValuesAsynchronously(forKeys: keys) { [weak self] in
                guard let self = self else { return }
                for key in keys {
                    let status = self.asset?.statusOfValue(forKey: key, error: nil)
                    if status == .failed {
                        NSLog("loading asset has failed. ")
                        return
                    }
                }
                let loadTime = Int(DispatchTime.now().uptimeNanoseconds - loadStartTick)
                NSLog("loading completed, elapsed: \(loadTime)")
                self.loadState = .loaded
            }
        } else {
            NSLog("load: already loading.. state: \(loadState.rawValue)")
        }
    }
}

class FeedVideoViewModel {
    var cellModels: [VideoCellModel]
    
    init (cellModels: [VideoCellModel]) {
        self.cellModels = cellModels
    }
    
    var cellCount: Int {
        cellModels.count
    }
    
    func cellModel(for indexPath: IndexPath) -> VideoCellModel {
        return cellModels[indexPath.row]
    }
}

class FeedImageViewModel {
    var cellModels: [ImageCellModel]
    
    init (cellModels: [ImageCellModel]) {
        self.cellModels = cellModels
    }
    
    var cellCount: Int {
        cellModels.count
    }
    
    func cellModel(for indexPath: IndexPath) -> ImageCellModel {
        return cellModels[indexPath.row]
    }
}

class FeedUIViewModel {
    private var sources = FeedDataSource.allVideos()
    private var filteredDataInfos: [FeedDataInfo]?
    
    private var isLoading: Bool = false
    
    private(set) var imageViewModel: FeedImageViewModel
    private(set) var videoViewModel: FeedVideoViewModel
    
    @BindableObject private(set) var headerViewModel: FeedHeaderViewModel
    @BindableObject private(set) var loadImageViewIfNeeded: Bool = false
    @BindableObject private(set) var updateImageViewIfNeeded: Bool = false

    init () {
        headerViewModel = FeedHeaderViewModel(cellModels: sources.videos.compactMap { video in video.category }.uniqued().map { CategoryCellModel(category: $0) })
        
        imageViewModel = FeedImageViewModel(cellModels: sources.videos.map {
            ImageCellModel(title: $0.title, url: $0.poster)
        })
        
        videoViewModel = FeedVideoViewModel(cellModels: sources.videos.map {
            VideoCellModel(title: $0.title, tags: $0.tags, url: $0.videoURL)
        })
    }
    
    private func updateCategoryViewModel() {
        let categories = sources.videos.map { video in video.category }.uniqued()
        let headerCategories = headerViewModel.cellModels.map { cellModel in cellModel.category }
        
        let newCategories = categories.filter { !headerCategories.contains($0) }.map {
            CategoryCellModel(category: $0)
        }
        
        headerViewModel.cellModels.append(contentsOf: newCategories)
    }
    
    internal func updateVideoViewModel() {
        videoViewModel = FeedVideoViewModel(cellModels: filteredDataInfos!.map {
            VideoCellModel(title: $0.title, tags: $0.tags, url: $0.videoURL)
        })
    }
    
    var videoList: [FeedDataInfo] {
        if let infos = filteredDataInfos {
            return infos
        } else {
            return [FeedDataInfo]()
        }
    }
    
    internal func updateImageViewModel(byFiltering category: String) {
        filteredDataInfos = sources.videos.filter{(video : FeedDataInfo) -> Bool in
            let doesCategoryMatch = (category == "전체") || (video.category == category)
            return doesCategoryMatch
        }
        
        imageViewModel = FeedImageViewModel(cellModels: filteredDataInfos!.map {
            ImageCellModel(title: $0.title, url: $0.poster)
        })
        
        if headerViewModel.selectedCategory != category {
            headerViewModel.selectedCategory = category
        }
    }
    
    internal func updateImageViewModel(with searchText: String) {
        filteredDataInfos = sources.videos.filter( { (video : FeedDataInfo) -> Bool in
            let doesCategoryMatch = (headerViewModel.selectedCategory == "전체") ||
                (video.category == headerViewModel.selectedCategory)
            if searchText.isEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && video.title.lowercased().contains(searchText.lowercased())
            }
        })
        
        imageViewModel = FeedImageViewModel(cellModels: filteredDataInfos!.map { ImageCellModel(title: $0.title, url: $0.poster) })
        
        loadImageViewIfNeeded.signal()
    }
    
    func fetchFeedSources() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global(qos: .userInteractive).async {
                let appendVideos = FeedDataSource.fetch().videos.filter {
                    !self.sources.videos.contains($0)
                }

                if 0 < appendVideos.count {
                    self.sources.append(contentsOf: appendVideos)
                    
                    self.updateImageViewModel(byFiltering: self.headerViewModel.selectedCategory)
                    self.updateCategoryViewModel()
                }
                
                self.isLoading = false
                self.updateImageViewIfNeeded.signal()
            }
        }
    }
}
