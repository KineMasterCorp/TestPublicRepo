//
//  PlayerObserver.swift
//  FeedUI
//
//  Created by JT3 on 2021/08/03.
//

import AVFoundation

protocol PlayerObserverDelegate: AnyObject {
    func didPlayToEndTime()
    func playbackLikelyToKeepUp()
}

class PlayerObserver {
    private var player: AVPlayer!
    private var index = 0

    private var itemObservation: NSKeyValueObservation?
    private var rateObservation: NSKeyValueObservation?
    private var statusObservation: NSKeyValueObservation?
    
    private var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    private var playbackBufferEmptyObserver: NSKeyValueObservation?
    private var playbackBufferFullObserver: NSKeyValueObservation?
    
    private var didFinishPlayingObserver: NSObjectProtocol?
    
    private var isRunning = true
    private var startTick: UInt64 = 0
    
    weak var playerDelegate: PlayerObserverDelegate?
    
    deinit {
        removeObservation()
    }
    
    private var bufferDuration: Float64 {
        if let range = player?.currentItem?.loadedTimeRanges.first?.timeRangeValue {
            return CMTimeGetSeconds(range.duration)
        }
        return 0
    }
    
    func start(player: AVPlayer, index: Int) {
        self.player = player
        self.index = index
        
        startTick = DispatchTime.now().uptimeNanoseconds
        
        setupObservation(for: player)
        
        isRunning = true
        
//        DispatchQueue.global().async {
//            while (self.isRunning) {
//                if self.observe() == false {
//                    break
//                }
//                usleep(5000)
//            }
//        }
    }
    
    func stop() {
        isRunning = false
        
        removeObservation()
    }
    
    private func observe() -> Bool {
        guard let item = player?.currentItem else { return false }
        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - startTick) / 1000000000
        
        var bufferLast: Float64 {
            if let range = item.loadedTimeRanges.first?.timeRangeValue {
                return CMTimeGetSeconds(range.end)
            }
            return 0
        }
        
        if item.duration != .indefinite {
            let contentDuration = CMTimeGetSeconds(item.duration)
            
            let accessLog = item.accessLog()?.events.last
            let downloadedBytes = accessLog?.numberOfBytesTransferred ?? 0
            let bitrate = Int(accessLog?.observedBitrate ?? 0)
            let bufferPercent = Int(bufferLast / contentDuration * 100)
            let avgBitrate = getAvgBitrate(log: accessLog)
            
            NSLog("[PlayerObserver] Index(\(index)) Elapsed: \(elapsed.formatted), state: \(item.status.rawValue), buffer: \(bufferLast) / \(contentDuration) (\(bufferPercent)%), downloaded: \(downloadedBytes), bit: \(avgBitrate), bw: \(bitrate), count: \(item.accessLog()?.events.count ?? 0)")
            
            if bufferLast >= contentDuration {
                return false
            }
        }
        
        return true
    }
    
    private func getAvgBitrate(log: AVPlayerItemAccessLogEvent?) -> Int {
        guard let log = log else { return -1 }
        if log.averageVideoBitrate > 0 { return Int(log.averageVideoBitrate) }
        if log.indicatedAverageBitrate > 0 { return Int(log.indicatedAverageBitrate) }
        if log.indicatedBitrate > 0 { return Int(log.indicatedBitrate) }
        return -1
    }
    
    private func setupObservation(for player: AVPlayer) {
        if let playerItem = player.currentItem {
            statusObservation = playerItem.observe(\.status, options:  [.new, .old]) { [weak self] (playerItem, change) in
                guard let self = self else { return }
                if playerItem.status == .readyToPlay {
                    let elapsed = Double(DispatchTime.now().uptimeNanoseconds - self.startTick) / 1000000000
                    NSLog("[Player \(self.index)] readyToPlay. elapsed: \(elapsed.formatted)")
                }
            }
            
            let playbackBufferEmptyKeyPath = \AVPlayerItem.isPlaybackBufferEmpty
            playbackBufferEmptyObserver = playerItem.observe(playbackBufferEmptyKeyPath, options: [.new]) { [weak self] (_, _) in
                guard let self = self else { return }
                let elapsed = Double(DispatchTime.now().uptimeNanoseconds - self.startTick) / 1000000000
                NSLog("[Player \(self.index)] isPlaybackBufferEmpty. elapsed: \(elapsed.formatted)")
            }
    
            playbackLikelyToKeepUpKeyPathObserver = playerItem.observe(\AVPlayerItem.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] (_, _) in
                guard let self = self else { return }
                let elapsed = Double(DispatchTime.now().uptimeNanoseconds - self.startTick) / 1000000000
                var numberOfBytesTransferred: Int64 = 0
                var observedBitrate = 0
                if let log = self.player?.currentItem?.accessLog()?.events.first {
                    numberOfBytesTransferred = log.numberOfBytesTransferred
                    observedBitrate = Int(log.observedBitrate)
                }

                NSLog("[Player \(self.index)] isPlaybackLikelyToKeepUp: \(player.currentItem?.isPlaybackLikelyToKeepUp ?? false) elapsed: \(elapsed.formatted), buffer: \(self.bufferDuration), downloaded: \(numberOfBytesTransferred), bw: \(observedBitrate)")
                if player.currentItem?.isPlaybackLikelyToKeepUp == true {
                    self.playerDelegate?.playbackLikelyToKeepUp()
                }
            }

            let playbackBufferFullKeyPath = \AVPlayerItem.isPlaybackBufferFull
            playbackBufferFullObserver = playerItem.observe(playbackBufferFullKeyPath, options: [.new]) { [weak self] (_, _) in
                guard let self = self else { return }
                let elapsed = Double(DispatchTime.now().uptimeNanoseconds - self.startTick) / 1000000000
                NSLog("[Player \(self.index)] isPlaybackBufferFull. elapsed: \(elapsed.formatted)")
            }
        }
        
        rateObservation = player.observe(\.rate, options:  [.new, .old], changeHandler: { [weak self] (player, change) in
            guard let self = self else { return }
            let elapsed = Double(DispatchTime.now().uptimeNanoseconds - self.startTick) / 1000000000
            NSLog("[Player \(self.index)] rate: \(player.rate). elapsed: \(elapsed.formatted)")
         })
        
        itemObservation = player.observe(\.timeControlStatus, options: [.new, .old]) { [weak self] player, change in
            guard let self = self else { return }
            let elapsed = Double(DispatchTime.now().uptimeNanoseconds - self.startTick) / 1000000000
            switch player.timeControlStatus {
            case .playing:
                NSLog("[Player \(self.index)] timeControlStatus.playing. elapsed: \(elapsed.formatted)")
            case .paused:
                NSLog("[Player \(self.index)] timeControlStatus.paused. elapsed: \(elapsed.formatted)")
                
            #if DEBUG
            case .waitingToPlayAtSpecifiedRate:
                //Log.info("timeControlStatus- .waitingToPlayAtSpecifiedRate")
                
                if let reason = player.reasonForWaitingToPlay {
                    
                    switch reason {
                    case .evaluatingBufferingRate:
                        //Log.info("timeControlStatus- .evaluatingBufferingRate")
                        break
                    case .toMinimizeStalls:
                        //Log.info("timeControlStatus- .toMinimizeStalls")
                        break
                    case .noItemToPlay:
                        //Log.info("timeControlStatus- .noItemToPlay")
                        break
                    default:
                        NSLog("[Player \(self.index)] reasonForWaitingToPlay unknown reason. \(reason.rawValue)")
                    }
                }
            #endif
            @unknown default:
                break
            }
        }
        
        didFinishPlayingObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { [weak self] _ in
            self?.playerDelegate?.didPlayToEndTime()
        }
    }
    
    private func removeObservation() {
        if let observer = itemObservation {
            observer.invalidate()
            itemObservation = nil
        }
        
        if let observer = statusObservation {
            observer.invalidate()
            statusObservation = nil
        }
        
        if let observer = rateObservation {
            observer.invalidate()
            rateObservation = nil
        }
        
        if let observer = playbackLikelyToKeepUpKeyPathObserver {
            observer.invalidate()
            playbackLikelyToKeepUpKeyPathObserver = nil
        }
        
        if let observer = playbackBufferEmptyObserver {
            observer.invalidate()
            playbackBufferEmptyObserver = nil
        }
        
        if let observer = playbackBufferFullObserver {
            observer.invalidate()
            playbackBufferFullObserver = nil
        }
        
        if didFinishPlayingObserver != nil {
            NotificationCenter.default.removeObserver(didFinishPlayingObserver as Any)
            didFinishPlayingObserver = nil
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        playerDelegate?.didPlayToEndTime()
    }
}

