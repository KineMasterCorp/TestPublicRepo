//
//  C.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/30.
//

import UIKit

struct FeedUI {
    static let backgroundColor = UIColor(red: CGFloat(31.0/255),
                                         green: CGFloat(33.0/255),
                                         blue: CGFloat(38.0/255.0),
                                         alpha: 1)
}

extension FeedUI {
    struct Category {
        static let selectedColor = UIColor.hexStringToUIColor(hex: "#ff5b5b")
        static let defaultColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.05)
    }
}
