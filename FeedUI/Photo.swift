//
//  Photo.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

struct Photo: Equatable {
    var caption: String
    var category: String
    var image: UIImage?
    var id: UUID = UUID()
    
    init(caption: String, category: String, image: String) {
        self.caption = caption
        self.category = category
        self.image = UIImage(named: image)
    }
    
    init?(dictionary: [String: String]) {
        guard let caption = dictionary["Caption"], let category = dictionary["Category"], let photo = dictionary["Photo"] else {
            return nil
        }
        self.init(caption: caption, category: category, image: photo)
    }
    
    static func allPhotos() -> [Photo] {
        var photos = [Photo]()
        guard let URL = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
              let photosFromPlist = NSArray(contentsOf: URL) as? [[String:String]] else {
            return photos
        }
        for dictionary in photosFromPlist {
            if let photo = Photo(dictionary: dictionary) {
                photos.append(photo)
            }
        }
        return photos
    }
    
}
