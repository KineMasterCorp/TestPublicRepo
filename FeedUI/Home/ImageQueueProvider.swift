//
//  ImageQueueProvider.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import Foundation

class ImageQueueProvider {
    private var backgroundIndex: Int = 0
    private let backgroundImages: [String] = {[
        "bg_home_01",
        "bg_home_02",
        "bg_home_03",
        "bg_home_04",
        "bg_home_05",
        "bg_home_06",
        "bg_home_07",
    ]}()
    
    func image() -> UIImage {
        return UIImage(named: backgroundImages[backgroundIndex])!
    }
    
    func nextImage() -> UIImage {
        backgroundIndex += 1
        let index = backgroundIndex % 7
        let image = UIImage(named: backgroundImages[index])!
        
        if 0 < backgroundIndex, 0 == (backgroundIndex % 7) {
            backgroundIndex = 0
        }
                
        return image
    }
}
