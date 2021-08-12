//
//  VideoCollectionViewModelOld.swift
//  FeedUI
//
//  Created by JT3 on 2021/07/29.
//

import AVFoundation

class VideoCollectionViewModelOld {
    private var sources: [FeedDataInfo]
    private(set) var currentVideo: Int = -1
    private var playerManager: PlayerManager

    init(sources: [FeedDataInfo], start videoIndex: Int, videoCache: VideoCache? = nil) {
        self.sources = sources
        currentVideo = videoIndex
        playerManager = PlayerManager(resourceLoaderDelegate: nil, start: videoIndex)
    }

    var videoCount: Int {
        sources.count
    }
    
    func getDataInfo(_ videoIndex: Int) -> FeedDataInfo? {
        return sources[videoIndex]
    }
    
    @discardableResult
    func preparePlayer(_ videoIndex: Int) -> AVPlayer {
        NSLog("preparePlayer \(videoIndex)")
        return playerManager.preparePlayer(for: sources[videoIndex].videoURL, videoIndex: videoIndex)
    }

    func doneUsingPlayer(_ videoIndex: Int) {
        NSLog("doneUsingPlayer \(videoIndex)")
        playerManager.doneUsingPlayer(videoIndex)
    }
    
    func setCurrentVideo(_ videoIndex: Int) {
        NSLog("setCurrentVideo: new video \(videoIndex), current video \(currentVideo)")
        guard currentVideo != videoIndex else { return }
        
        currentVideo = videoIndex
        playerManager.play(at: videoIndex)
    }
    
    func play() {
        playerManager.play()
    }
    
    func pause() {
        playerManager.pause()
    }
}
