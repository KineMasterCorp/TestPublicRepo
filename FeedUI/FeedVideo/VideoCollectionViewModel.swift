//
//  VideoCollectionViewModel.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import AVFoundation

typealias VideoCollectionViewModel = VideoCollectionViewModelNew
//typealias VideoCollectionViewModel = VideoCollectionViewModelOld

class VideoCollectionViewModelNew {
    private var sources: [FeedDataInfo]
    private(set) var currentVideo: Int = -1
    private var videoLoader: VideoLoader
    private var playerManager: PlayerManager
    
    private let fakeURLScheme = "KM-"
    
    private let prefetchCount = 2
    private let preloadingSize = 1100*1024
    
    init(sources: [FeedDataInfo], start videoIndex: Int, videoCache: VideoCache? = nil) {
        self.sources = sources
        videoLoader = VideoLoader(urlSchemePrefix: fakeURLScheme, videoCache: videoCache)
        playerManager = PlayerManager(resourceLoaderDelegate: videoLoader, start: videoIndex)

        preparePlayer(videoIndex)
        setCurrentVideo(videoIndex)
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
        let fakeURLString = fakeURLScheme + sources[videoIndex].videoURL.absoluteString
        let fakeURL = URL(string: fakeURLString) ?? sources[videoIndex].videoURL
        return playerManager.preparePlayer(for: fakeURL, videoIndex: videoIndex)
    }

    func doneUsingPlayer(_ videoIndex: Int) {
        NSLog("doneUsingPlayer \(videoIndex)")
        playerManager.doneUsingPlayer(videoIndex)
    }
    
    private func prepareLoad(for videoIndex: Int) {
        videoLoader.cancelLoading(except: sources[videoIndex].videoURL)
        videoLoader.load(url: sources[videoIndex].videoURL)
        
        // Set prefetch.
        preload()
    }
    
    func setCurrentVideo(_ videoIndex: Int) {
        NSLog("setCurrentVideo: new video \(videoIndex), current video \(currentVideo)")
        guard currentVideo != videoIndex else { return }
        
        currentVideo = videoIndex
        
        prepareLoad(for: videoIndex)
        playerManager.play(at: videoIndex)
    }
    
    func play() {
        playerManager.play()
    }
    
    func pause() {
        playerManager.pause()
    }
    
    private func preload() {
        for i in (1...prefetchCount) {
            if currentVideo + i < sources.count {
                NSLog("setCurrentVideo: preload for \(currentVideo + i), size: \(preloadingSize)")
                videoLoader.load(url: sources[currentVideo + i].videoURL, length: preloadingSize)
            }
            if currentVideo - i >= 0 {
                NSLog("setCurrentVideo: preload for \(currentVideo - i), size: \(preloadingSize)")
                videoLoader.load(url: sources[currentVideo - i].videoURL, length: preloadingSize)
            }
        }
    }
}
