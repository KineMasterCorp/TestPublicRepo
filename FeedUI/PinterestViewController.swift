//
//  PinterestViewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class PinterestViewController: UICollectionViewController {
    var photos = Photo.allPhotos()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
        // Set the PinterestLayout delegate
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
}

extension PinterestViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath)
    if let annotateCell = cell as? AnnotatedPhotoCell {
      annotateCell.photo = photos[indexPath.item]
    }
    return cell
  }
  
}

//MARK: - PINTEREST LAYOUT DELEGATE
extension PinterestViewController : PinterestLayoutDelegate {
  
  // 1. Returns the photo height
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    return photos[indexPath.item].image.size.height
  }

}
