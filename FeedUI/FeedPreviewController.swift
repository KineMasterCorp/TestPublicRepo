//
//  FeedPreviewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class FeedPreview: UICollectionView {    
//    var photos = Photo.allPhotos()
//    var filteredPhotos = [Photo]()
    
    var feedInfoDelegate: FeedInfoDelegate?
    
    var sources = VideoDataSource.allVideos()
    
    lazy var filteredSources: VideoDataSource = {
        let videos = [VideoDataInfo]()
        return VideoDataSource(videos: videos)
    }()
}

protocol FeedInfoDelegate: AnyObject {
    func notify(photo: Photo) -> Void
}

extension FeedPreview: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSources.dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photo = filteredSources.getPhoto(of: indexPath.item) {
            feedInfoDelegate?.notify(photo: photo)
        }        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath)
        if let feedCell = cell as? FeedCell {
            feedCell.photo = filteredSources.getPhoto(of: indexPath.item)
        }
        return cell
    }
}

extension FeedPreview: PinterestLayoutDelegate {
    // return height
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 150
        if let photo = filteredSources.getPhoto(of: indexPath.item), let image = photo.image {
            height = max(height, image.size.height / 3)
        }
        
        return min(300, height)
    }
}
