//
//  FeedImageCollectionViewModel.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/30.
//

import Foundation

struct FeedImageCellModel {
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

class FeedImageCollectionViewModel {
    var cellModels: [FeedImageCellModel]
    
    init (cellModels: [FeedImageCellModel]) {
        self.cellModels = cellModels
    }
    
    var cellCount: Int {
        cellModels.count
    }
    
    func cellModel(for indexPath: IndexPath) -> FeedImageCellModel {
        return cellModels[indexPath.row]
    }
}
