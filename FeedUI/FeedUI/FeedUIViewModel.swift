//
//  FeedUIViewModel.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import Foundation
import AVFoundation

class FeedUIViewModel {
    let defaultInitialCategoryIndex: Int = 0
    
    @BindableObject private(set) var headerViewModel: FeedHeaderViewModel
    @BindableObject private(set) var loadImageViewIfNeeded: Bool = false
    @BindableObject private(set) var updateImageViewIfNeeded: Bool = false
    
    private(set) var sources = [FeedDataInfo]()
    private(set) var imageCollectionViewModel: FeedImageCollectionViewModel
    
    private var dummyDataFetcher = DummyFeedDataFetcher()
    private var isLoading: Bool = false
    private var fetchRequest: FeedDataRequest
    
    init (fetchRequest: FeedDataRequest = .init(target: "전체", type: .category)) {
        self.fetchRequest = fetchRequest
        
        headerViewModel = FeedHeaderViewModel(cellModels: [CategoryCellModel]())
        imageCollectionViewModel = FeedImageCollectionViewModel(cellModels: [FeedImageCellModel]())
    }
    
    private func updateCategoryViewModel() {
        let categories = sources.map { video in video.category }.uniqued()
        let headerCategories = headerViewModel.cellModels.map { cellModel in cellModel.category }
        
        let newCategories = categories.filter { !headerCategories.contains($0) }.map {
            CategoryCellModel(category: $0)
        }
        
        if !newCategories.isEmpty {
            headerViewModel.cellModels.append(contentsOf: newCategories)
        }        
    }
    
    private func updateImageViewModel() {
        imageCollectionViewModel = FeedImageCollectionViewModel(cellModels: sources.map {
            FeedImageCellModel(title: $0.title, url: $0.poster)
        })
    }
    
    internal func fetch(with request: FeedDataRequest) {
        fetchRequest = request
        
        sources = DummyFeedDataFetcher.fetch(with: fetchRequest)
        
        updateImageViewModel()
        loadImageViewIfNeeded.signal()
        
        if headerViewModel.selectedCategory != fetchRequest.target {
            headerViewModel.selectedCategory = fetchRequest.target
            
            updateCategoryViewModel()
        }
    }
       
    internal func fetchNext() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global(qos: .userInteractive).async {
                let appendVideos = DummyFeedDataFetcher.fetch(with: self.fetchRequest, fetchNext: true).filter {
                    !self.sources.contains($0)
                }

                if 0 < appendVideos.count {
                    self.sources.append(contentsOf: appendVideos)
                    
                    self.updateImageViewModel()
                    self.updateCategoryViewModel()
                }
                
                self.isLoading = false
                self.updateImageViewIfNeeded.signal()
            }
        }
    }
}
