//
//  VideoCollectionViewModel.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import AVFoundation

class VideoCollectionViewModel {
    private var sources: [FeedDataInfo]
    private(set) var currentVideo: Int
    private var videoLoader: VideoLoader
    private var playerManager: PlayerManager
    
    private let fakeURLScheme = "KM-"

    init(sources: [FeedDataInfo], start videoIndex: Int) {
        self.sources = sources
        currentVideo = videoIndex
        videoLoader = VideoLoader(urlSchemePrefix: fakeURLScheme)
        playerManager = PlayerManager(resourceLoaderDelegate: videoLoader, start: videoIndex)
    }

    var videoCount: Int {
        sources.count
    }
    
    func getDataInfo(_ videoIndex: Int) -> FeedDataInfo? {
        return sources[videoIndex]
    }
    
    func getPlayer(_ videoIndex: Int) -> AVPlayer {
        NSLog("getPlayer \(videoIndex)")
//        let fakeURLString = fakeURLScheme + sources[videoIndex].videoURL.absoluteString
//        let fakeURL = URL(string: fakeURLString) ?? sources[videoIndex].videoURL
//        return playerManager.preparePlayer(for: fakeURL, videoIndex: videoIndex)
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
        videoLoader.cancelLoading(except: sources[videoIndex].videoURL)
        playerManager.play(at: videoIndex)
//        for i in (index+1...index+3) {
//            if i >= sources.count {
//                break
//            }
//            videoLoader.preload(url: sources[i].videoURL)
//        }
    }
}
