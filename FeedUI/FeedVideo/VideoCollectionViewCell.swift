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

    private var playerLayer: AVPlayerLayer?
    private var videoManager: VideoCollectionViewModel!
    private var videoIndex = 0
    
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
        print("videoCell \(videoIndex) deinit")
    }
    
    public func configure(with videoManager: VideoCollectionViewModel, index: Int) {
        NSLog("videoCell configure index: \(index)")
        self.videoManager = videoManager
        videoIndex = index
        let player = videoManager.preparePlayer(index)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = contentView.bounds
        playerLayer!.videoGravity = .resizeAspectFill
        
        contentView.layer.addSublayer(playerLayer!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NSLog("prepareForReuse index: \(videoIndex)")

        videoManager?.doneUsingPlayer(videoIndex)
        playerLayer?.player = nil   // Workaround code for old devices like iPhone 5s.
                                    // If we scroll the screen very fast, only black screen is shown on the device with playing only audio.
        playerLayer?.removeFromSuperlayer()
    }
}
