//
//  AudioManager.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 10/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import AVFoundation

public class AudioManager {
    static let shared = AudioManager()

    private init() {}
    
    private var players: [AVAudioPlayer] = []
    private var playsWithoutDeallocating = 0
    private var maximumPlaysWithoutDeallocating = 10
    
    func playAudio(named filename: String, volume: Float = 0.8, shouldLoop: Bool = false) {
        var newPlayer: AVAudioPlayer?
        guard let path = Bundle.main.path(forResource: filename, ofType: nil, inDirectory: "SoundEffects") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer?.volume = volume
            newPlayer?.numberOfLoops = (shouldLoop) ? -1 : 0
            newPlayer?.play()
            if let player = newPlayer {
                players.append(player)
                playsWithoutDeallocating += 1
            }
        } catch {
            // couldn't load file :(
        }
        
        if playsWithoutDeallocating > maximumPlaysWithoutDeallocating {
            self.deallocateUnusedPlayers()
        }
    }
    
    func deallocateUnusedPlayers() {
        for player in players {
            if !player.isPlaying {
                if let index = players.firstIndex(of: player) {
                    players.remove(at: index)
                }
            }
        }
    }
    
    func reset() {
        self.players.forEach({$0.stop()})
        self.players = []
    }
    
}
