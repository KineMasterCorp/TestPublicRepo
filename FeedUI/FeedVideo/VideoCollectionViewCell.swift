//
//  VideoCollectionViewCell.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/25.
//

import UIKit
import AVFoundation

protocol CellDelegate: AnyObject {
    func close() -> Void
}

class VideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "VideoCollectionViewCell"
    // Subviews
    var player: AVPlayer?
    var index: Int = -1
    private var playerLayer: AVPlayerLayer?
    
    //private var delegate: CellDelegate?
    
//    private lazy var closeButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        let image = UIImage(named: "xmark")?.withRenderingMode(.alwaysTemplate)
//        button.setImage(image, for: .normal)
//        button.tintColor = .white
//        button.addTarget(target, action: #selector(closeButtonTapped), for: .touchUpInside)
//        return button
//    } ()
    
//    private var closeButton = UIButton()
//
//    @objc func closeButtonTapped(_ sender: Any) {
//        delegate?.close()
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .black
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with dataSource: VideoDataSource, index: Int) {
        NSLog("configure cell with \(index)")
        self.index = index
        configureVideo(dataSource: dataSource)
    }
    
    private func configureVideo(dataSource: VideoDataSource) {
        guard let asset = dataSource.getVideo(of: index) else {
            NSLog("configureVideo: couldn't get video asset for \(index)")
            return
        }
        let playerItem = AVPlayerItem(asset: asset)

        if player != nil {
            NSLog("reuse player. count: \(AVPlayer.instanceCount)")
            player!.replaceCurrentItem(with: playerItem)
        } else {
            AVPlayer.instanceCount += 1
            NSLog("create new player. count: \(AVPlayer.instanceCount)")
            player = AVPlayer(playerItem: playerItem)
        }
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = contentView.bounds
        playerLayer!.videoGravity = .resizeAspectFill
        
        contentView.layer.addSublayer(playerLayer!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NSLog("prepareForReuse: \(index)")
        
        playerLayer?.removeFromSuperlayer()
        
//        if let layers = contentView.layer.sublayers {
//            for layer in layers {
//                if layer == playerLayer {
//                    NSLog("remove layer")
//                    layer.removeFromSuperlayer()
//                }
//            }
//        }
    }
}

extension AVPlayer {
    static var instanceCount: Int = 0
}
