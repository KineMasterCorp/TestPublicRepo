//
//  InitialViewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/28.
//

import UIKit

class InitialViewController: UIViewController {
    var backgroundIndex: Int = 0
    let backgroundImages: [String] = {[
        "bg_home_01",
        "bg_home_02",
        "bg_home_03",
        "bg_home_04",
        "bg_home_05",
        "bg_home_06",
        "bg_home_07",
    ]}()
    
    private lazy var feedButton: ActualGradientButton = {
        let button = ActualGradientButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "icFeed")
        button.setImage(image, for: .normal)
        button.addTarget(target, action: #selector(feedButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    private var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        view.addSubview(feedButton)
        
        feedButton.setTitle("프로젝트 받기", for: .normal)
        
        NSLayoutConstraint.activate([
            feedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            feedButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(reservedBackgroundView)
        view.sendSubviewToBack(reservedBackgroundView)
        
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
                
        setBackgroundImages()
        setBackgroundAnimations(duration: 10)
    }
    
    lazy var backgroundView: UIImageView = {
        let view = UIImageView(frame: view.frame)
        return view
    }()
    
    lazy var reservedBackgroundView: UIImageView = {
        let view = UIImageView(frame: view.frame)
        return view
    }()
    
    private var animator: UIViewPropertyAnimator?    
    private var offset: CGFloat = 50
    
    @objc func setBackgroundImages() {
        let index = backgroundIndex % 7
        let imageName = backgroundImages[index]
        backgroundView.image = UIImage(named: imageName)
        backgroundIndex += 1
        if 0 < backgroundIndex, 0 == (backgroundIndex % 7) {
            backgroundIndex = 0
        }
        
        let imageName2 = backgroundImages[backgroundIndex]
        reservedBackgroundView.image = UIImage(named: imageName2)
        
        //print("new background index : \(index), \(backgroundIndex)")
    }
    
    func setBackgroundAnimations(duration speed: CGFloat) {
        backgroundView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        reservedBackgroundView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        reservedBackgroundView.alpha = 0.1
                
        animator = UIViewPropertyAnimator(duration: TimeInterval(speed), curve: .linear) {
            self.backgroundView.center.x = self.view.center.x + self.offset
            self.backgroundView.center.y = self.view.center.y + self.offset
            self.backgroundView.alpha = 0.1
            
            self.reservedBackgroundView.center.x = self.view.center.x + self.offset
            self.reservedBackgroundView.center.y = self.view.center.y + self.offset
            self.reservedBackgroundView.alpha = 1
        }
        
        animator?.addCompletion { _ in
            self.backgroundView.alpha = 1
            self.backgroundView.center.x = self.view.center.x + self.offset
            self.backgroundView.center.y = self.view.center.y + self.offset
            
            self.reservedBackgroundView.center.x = self.view.center.x + self.offset
            self.reservedBackgroundView.center.y = self.view.center.y + self.offset
            
            self.offset *= -1
            
            self.setBackgroundImages()
            self.setBackgroundAnimations(duration: 10)
        }
        
        animator?.startAnimation()
    }
    
    @objc internal func feedButtonTapped(_ sender: Any) {
        animator?.stopAnimation(true)
        let modalView = MasterViewController()        
        modalView.modalPresentationStyle = .fullScreen
        present(modalView, animated: true) {
        }
    }
}

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

extension UIButton {
    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
}
