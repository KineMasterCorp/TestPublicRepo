//
//  PlayerManager.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/25.
//

import AVFoundation

protocol PlayerDelegate: AnyObject {
    func didPlayToEndTime(playerInfo: PlayerInfo)
    func playbackLikelyToKeepUp(playerInfo: PlayerInfo)
}

class PlayerInfo: NSObject {
    var videoIndex: Int
    var videoURL: URL
    var resourceLoaderDelegate: AVAssetResourceLoaderDelegate
    weak var playerDelegate: PlayerDelegate?
    var isPlaying = false
    
    private var player: AVPlayer?
    private var playbackLikelyToKeepUpContext = 0
    private var playerLoadTime: UInt64 = 0
    private var didFinishPlayingObserver: NSObjectProtocol?

    init(videoURL: URL, videoIndex: Int, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) {
        self.videoURL = videoURL
        self.videoIndex = videoIndex
        self.resourceLoaderDelegate = resourceLoaderDelegate
    }
    
    deinit {
        NSLog("PlayerInfo \(videoIndex) deinit")
        player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
        
        if didFinishPlayingObserver != nil {
            NotificationCenter.default.removeObserver(didFinishPlayingObserver as Any)
            didFinishPlayingObserver = nil
        }
    }
    
    func preparePlayer() -> AVPlayer {
        playerLoadTime = DispatchTime.now().uptimeNanoseconds
        let asset = AVURLAsset(url: videoURL)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        player!.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                options: .new, context: &playbackLikelyToKeepUpContext)

        return player!
    }
    func getPlayer() -> AVPlayer? {
        return player
    }
    
    func play() {
        isPlaying = true
        if didFinishPlayingObserver == nil {
            didFinishPlayingObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { [weak self] _ in
                guard let self = self else { return }
                self.playerDelegate?.didPlayToEndTime(playerInfo: self)
            }
        }

        player?.play()
    }
    
    func replay() {
        isPlaying = true
        player?.seek(to: .zero) { [weak self] _ in
            self?.play()
        }
    }
    
    func stop() {
        if didFinishPlayingObserver != nil {
            NotificationCenter.default.removeObserver(didFinishPlayingObserver as Any)
            didFinishPlayingObserver = nil
        }
        player?.pause()
        player?.seek(to: .zero)
        
        isPlaying = false
    }

    @objc private func playerDidFinishPlaying() {
        playerDelegate?.didPlayToEndTime(playerInfo: self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playbackLikelyToKeepUpContext {
            let elapsed = Int((DispatchTime.now().uptimeNanoseconds - playerLoadTime) / 1000000)
            if player?.currentItem?.isPlaybackLikelyToKeepUp == true {
                NSLog("Player \(videoIndex) ready to play. elapsed: \(elapsed), buffer: \(bufferDuration)")
                playerDelegate?.playbackLikelyToKeepUp(playerInfo: self)
            } else {
                NSLog("Player \(videoIndex) is not ready yet. elapsed: \(elapsed), buffer: \(bufferDuration)")
            }
        }
    }
    
    private var bufferDuration: Float64 {
        if let range = player?.currentItem?.loadedTimeRanges.first?.timeRangeValue {
            return CMTimeGetSeconds(range.duration)
        }
        return 0
    }
}

class PlayerManager {
    private var players = [PlayerInfo]()
    private var resourceLoaderDelegate: AVAssetResourceLoaderDelegate
    private var currentVideo: Int = 0

    init(resourceLoaderDelegate: AVAssetResourceLoaderDelegate, start videoIndex: Int) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        currentVideo = videoIndex
    }
    
    func preparePlayer(for url: URL, videoIndex: Int) -> AVPlayer {
        if let playerInfo = getPlayerInfo(byVideoIndex: videoIndex) {
            if let player = playerInfo.getPlayer() {
                NSLog("preparePlayer: reuse player for \(videoIndex). total count: \(players.count)")
                return player
            } else {
                NSLog("preparePlayer: player is not created for \(videoIndex). total count: \(players.count)")
                doneUsingPlayer(videoIndex)
            }
        }

        let playerInfo = PlayerInfo(videoURL: url, videoIndex: videoIndex, resourceLoaderDelegate: resourceLoaderDelegate)
        playerInfo.playerDelegate = self

        players.append(playerInfo)

        NSLog("preparePlayer: new player for \(videoIndex). total count: \(players.count)")
        
        for player in players {
            NSLog("preparePlayer: player \(player.videoIndex)")
        }

        return playerInfo.preparePlayer()
    }
    
    func doneUsingPlayer(_ videoIndex: Int) {
        guard let playerIndex = getPlayerIndex(byVideoIndex: videoIndex) else {
            print("doneUsingPlayer: no matching player! videoIndex: \(videoIndex)")
            return
        }
        players.remove(at: playerIndex)
        print("doneUsingPlayer \(videoIndex). remain player: \(players.count)")
    }
    
    func play(at videoIndex: Int) {
        // Stop all the other players.
        for playerInfo in players {
            if playerInfo.videoIndex == videoIndex {
                currentVideo = videoIndex
                playerInfo.play()
            } else {
                playerInfo.stop()
            }
        }
    }

    private func getPlayerInfo(byVideoIndex videoIndex: Int) -> PlayerInfo? {
        return players.first(where: { $0.videoIndex == videoIndex })
    }
    
    private func getPlayerIndex(byVideoIndex videoIndex: Int) -> Array<PlayerInfo>.Index? {
        players.firstIndex( where: { $0.videoIndex == videoIndex })
    }
}

extension PlayerManager: PlayerDelegate {
    func didPlayToEndTime(playerInfo: PlayerInfo) {
        NSLog("didPlayToEndTime called for \(playerInfo.videoIndex), current: \(currentVideo)")
        if currentVideo == playerInfo.videoIndex {
            playerInfo.replay()
        } else {
            playerInfo.stop()
        }
    }
    
    func playbackLikelyToKeepUp(playerInfo: PlayerInfo) {
        NSLog("playbackLikelyToKeepUp called for \(playerInfo.videoIndex), current: \(currentVideo), isPlaying: \(playerInfo.isPlaying)")
        if currentVideo == playerInfo.videoIndex && playerInfo.isPlaying == false {
            playerInfo.play()
        }
    }
}
