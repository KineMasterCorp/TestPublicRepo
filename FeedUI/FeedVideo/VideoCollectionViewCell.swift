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
    //var index: Int = -1
    private var playerLayer: AVPlayerLayer?
    
//    private lazy var vStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 10
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.tintColor = .white
//        
//        return stackView
//    }()
//        
//    var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        label.textColor = .white
//        return label
//    } ()
//    
//    var tagLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        label.textColor = .white
//        return label
//    } ()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .black
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player = nil
        AVPlayer.instanceCount -= 1
    }

//    public func configure(with dataSource: FeedDataSource, index: Int) {
//        NSLog("configure cell with \(index)")
//        self.index = index
//        configureVideo(dataSource: dataSource)
//    }
    
    public func configure(with cellModel: VideoCellModel) {
        guard let asset = cellModel.asset else { return }
        
        let playerItem = AVPlayerItem(asset: asset)

        if player != nil {
            NSLog("reuse player. count: \(AVPlayer.instanceCount)")
            player!.replaceCurrentItem(with: playerItem)
        } else {
            AVPlayer.instanceCount += 1
            NSLog("create new player. count: \(AVPlayer.instanceCount)")
            player = AVPlayer(playerItem: playerItem)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = contentView.bounds
        playerLayer!.videoGravity = .resizeAspectFill
        
        contentView.layer.addSublayer(playerLayer!)
    }
    
//    private func configureVideo(dataSource: FeedDataSource) {
//        guard let asset = dataSource.getVideo(of: index) else {
//            NSLog("configureVideo: couldn't get video asset for \(index)")
//            return
//        }
//        let playerItem = AVPlayerItem(asset: asset)
//
//        if player != nil {
//            NSLog("reuse player. count: \(AVPlayer.instanceCount)")
//            player!.replaceCurrentItem(with: playerItem)
//        } else {
//            AVPlayer.instanceCount += 1
//            NSLog("create new player. count: \(AVPlayer.instanceCount)")
//            player = AVPlayer(playerItem: playerItem)
//        }
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
//        
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer!.frame = contentView.bounds
//        playerLayer!.videoGravity = .resizeAspectFill
//        
//        contentView.layer.addSublayer(playerLayer!)
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //NSLog("prepareForReuse: \(index)")
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        player = nil
        AVPlayer.instanceCount -= 1
        playerLayer?.player = nil   // Workaround code for old devices like iPhone 5s.
                                    // If we scroll the screen very fast, only black screen is shown on the device with playing only audio.
        playerLayer?.removeFromSuperlayer()
    }
    
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: CMTime.zero)
        player?.play()
    }
}

extension AVPlayer {
    static var instanceCount: Int = 0
}
