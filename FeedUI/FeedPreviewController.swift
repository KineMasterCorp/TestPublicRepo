//
//  FeedPreviewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class FeedPreview: UICollectionView {    
    var photos = Photo.allPhotos()
    var filteredPhotos = [Photo]()    
}

extension FeedPreview: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath)
        if let feedCell = cell as? FeedCell {
            feedCell.photo = filteredPhotos[indexPath.item]
        }
        return cell
    }
}

extension FeedPreview: PinterestLayoutDelegate {
    // return height
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {        
        return min(300, max(150, photos[indexPath.item].image.size.height / 3))
    }
}
