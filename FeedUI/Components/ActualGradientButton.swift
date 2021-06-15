//
//  ActualGradientButton.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import UIKit

class ActualGradientButton: UIButton {
    public class var color1: UIColor {
        return UIColor(red: 88 / 255, green: 222 / 255, blue: 252 / 255, alpha: 1.0)
    }
    
    public class var color2: UIColor {
        return UIColor(red: 92 / 255, green: 130 / 255, blue: 253 / 255, alpha: 1.0)
    }
    
    public class var color3: UIColor {
        return UIColor(red: 118 / 255, green: 51 / 255, blue: 253 / 255, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        setInsets(forContentPadding: .init(top: 0, left: 25, bottom: 0, right: 25), imageTitlePadding: 10)
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [ActualGradientButton.color1.cgColor,
                    ActualGradientButton.color2.cgColor,
                    ActualGradientButton.color3.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 10
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
