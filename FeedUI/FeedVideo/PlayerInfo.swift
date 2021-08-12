//
//  PlayerInfo.swift
//  FeedUI
//
//  Created by JT3 on 2021/08/03.
//

import AVFoundation

protocol PlayerDelegate: AnyObject {
    func didPlayToEndTime(playerInfo: PlayerInfo)
    func playbackLikelyToKeepUp(playerInfo: PlayerInfo)
}

class PlayerInfo: NSObject {
    var videoIndex: Int
    var isPlaying = false

    private var videoURL: URL
    private weak var resourceLoaderDelegate: AVAssetResourceLoaderDelegate?
    private weak var playerDelegate: PlayerDelegate?
    
    private var player: AVPlayer?
    
    private let observer = PlayerObserver()

    init(videoURL: URL, videoIndex: Int, resourceLoaderDelegate: AVAssetResourceLoaderDelegate?, playerDelegate: PlayerDelegate? = nil) {
        self.videoURL = videoURL
        self.videoIndex = videoIndex
        self.resourceLoaderDelegate = resourceLoaderDelegate
        self.playerDelegate = playerDelegate
        
        super.init()

        observer.playerDelegate = self
    }
    
    deinit {
        NSLog("PlayerInfo \(videoIndex) deinit")
        observer.stop()
    }
    
    func preparePlayer() -> AVPlayer {
        let asset = AVURLAsset(url: videoURL)
        if resourceLoaderDelegate != nil {
            asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.global(qos: .userInitiated))
        }
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        observer.start(player: player!, index: videoIndex)

        return player!
    }
    func getPlayer() -> AVPlayer? {
        return player
    }
    
    func play() {
        isPlaying = true

        player?.play()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func replay() {
        isPlaying = true
        player?.seek(to: .zero) { [weak self] _ in
            self?.play()
        }
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        
        isPlaying = false
    }
}

extension PlayerInfo: PlayerObserverDelegate {
    func didPlayToEndTime() {
        playerDelegate?.didPlayToEndTime(playerInfo: self)
    }
    func playbackLikelyToKeepUp() {
        playerDelegate?.playbackLikelyToKeepUp(playerInfo: self)
    }
}
