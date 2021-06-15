//
//  SequentialBackgroundView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import UIKit

class SequentialBackgroundView: UIView {
    private let imageQueueProvider = ImageQueueProvider()
    
    private var backgroundView: UIImageView!
    private var reservedBackgroundView: UIImageView!
    
    private var animator: UIViewPropertyAnimator?
    private var backgroundPosOffset: CGFloat = 50
    private var backgroundFlowDuration: TimeInterval = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        reservedBackgroundView = UIImageView(frame: frame)
        addSubview(reservedBackgroundView)
        sendSubviewToBack(reservedBackgroundView)
        
        backgroundView = UIImageView(frame: frame)
        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        
        setBackgroundImages()
        setBackgroundAnimations(duration: backgroundFlowDuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setAnimatingState(_ animate: Bool) {
        animate ? setBackgroundAnimations(duration: backgroundFlowDuration) : self.animator?.stopAnimation(true)
    }
        
    private func setBackgroundImages() {
        backgroundView.image = imageQueueProvider.image()
        reservedBackgroundView.image = imageQueueProvider.nextImage()
    }
    
    private func setBackgroundAnimations(duration speed: TimeInterval) {
        backgroundView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        reservedBackgroundView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        reservedBackgroundView.alpha = 0.1
                
        animator = UIViewPropertyAnimator(duration: speed, curve: .linear) {
            self.backgroundView.center.x = self.center.x + self.backgroundPosOffset
            self.backgroundView.center.y = self.center.y + self.backgroundPosOffset
            self.backgroundView.alpha = 0.1
            
            self.reservedBackgroundView.center.x = self.center.x + self.backgroundPosOffset
            self.reservedBackgroundView.center.y = self.center.y + self.backgroundPosOffset
            self.reservedBackgroundView.alpha = 1
        }
        
        animator?.addCompletion { position in
            if position == .end {
                self.backgroundView.alpha = 1
                self.backgroundView.center.x = self.center.x + self.backgroundPosOffset
                self.backgroundView.center.y = self.center.y + self.backgroundPosOffset
                
                self.reservedBackgroundView.center.x = self.center.x + self.backgroundPosOffset
                self.reservedBackgroundView.center.y = self.center.y + self.backgroundPosOffset
                
                self.backgroundPosOffset *= -1
                
                self.setBackgroundImages()
                self.setBackgroundAnimations(duration: speed)
            }
        }
        
        animator?.startAnimation()
    }
}
