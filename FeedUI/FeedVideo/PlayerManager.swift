//
//  PlayerManager.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/25.
//

import AVFoundation

class PlayerManager {
    private var players = [PlayerInfo]()
    private weak var resourceLoaderDelegate: AVAssetResourceLoaderDelegate?
    private var currentVideo: Int = 0
    private var userPaused: Bool = false

    init(resourceLoaderDelegate: AVAssetResourceLoaderDelegate?, start videoIndex: Int) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        currentVideo = videoIndex
    }
    
    @discardableResult
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

        let playerInfo = PlayerInfo(videoURL: url, videoIndex: videoIndex, resourceLoaderDelegate: resourceLoaderDelegate, playerDelegate: self)

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
    
    func pause() {
        players.first(where: { $0.videoIndex == currentVideo })?.pause()
        userPaused = true
    }
    
    func play() {
        players.first(where: { $0.videoIndex == currentVideo })?.play()
        userPaused = false
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
        NSLog("playbackLikelyToKeepUp called for \(playerInfo.videoIndex), current: \(currentVideo), isPlaying: \(playerInfo.isPlaying), userPaused: \(userPaused)")
        if currentVideo == playerInfo.videoIndex && playerInfo.isPlaying == false, !userPaused {
            playerInfo.play()
        }
    }
}
