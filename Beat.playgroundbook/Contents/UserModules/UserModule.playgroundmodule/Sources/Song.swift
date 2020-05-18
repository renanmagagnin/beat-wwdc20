//
//  Song.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 09/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import Foundation
import CoreGraphics

struct AdditionalLayer {
    let fileName: String
    let volume: Float
    let delay: TimeInterval
    let shouldLoop: Bool
    
    init(fileName: String, volume: Float = 1.0, delay: TimeInterval, shouldLoop: Bool = true) {
        self.fileName = fileName
        self.volume = volume
        self.delay = delay
        self.shouldLoop = shouldLoop
    }
}

struct Song {
    var beats: [Beat]
    // Next: For every beat, a layer that is unlocked. The last one should be vocals.
    var additionalLayers: [Int: [AdditionalLayer]]
    
    init(beats: [Beat], additionalLayers: [Int: [AdditionalLayer]] = [:]) {
        self.beats = beats
        self.additionalLayers = additionalLayers
    }
}

// MARK: Custom Songs
extension Song {
    
    static func doIWannaKnow() -> Song {
        let doIWannaKnowTranslation = -1
        
        let bass = Beat(soundEffectFileName: "bassArticMonkeys.m4a", loop: [0, 8], bpm: 85, translation: doIWannaKnowTranslation, volume: 0.7)
        let bassAndSnare = Beat(soundEffectFileName: "Bass+SnareArticMonkeys.m4a", loop: [4, 12], bpm: 85, translation: doIWannaKnowTranslation, volume: 0.6)
        
        let additionalLayers = [1: [AdditionalLayer(fileName: "guitarArticMonkeys.m4a", volume: 0.1, delay: bass.eightNoteDuration * TimeInterval(10.5))]]
        
        return Song(beats: [bass, bassAndSnare], additionalLayers: additionalLayers)
    }
    
    static func weWillRockYou() -> Song {
        let weWillRockYouTranslation = 3
        
        let weWillRockYouBass = Beat(soundEffectFileName: "kick_pozzan.mp3", loop: [0, 2, 8, 10], bpm: 81, translation: weWillRockYouTranslation, volume: 0.7)
        let weWillRockYouHat = Beat(soundEffectFileName: "808-clap-1.wav", loop: [4, 12], bpm: 81, translation: weWillRockYouTranslation, volume: 0.7)
        
        let additionalLayers = [1: [AdditionalLayer(fileName: "We_Will_Rock_You_Vocals.m4a", volume: 0.4, delay: 0.585)]]
        
        return Song (beats: [weWillRockYouBass, weWillRockYouHat], additionalLayers: additionalLayers)
    }
    
    static func superstição() -> Song {
        let superstiçãoTranslation = 3
        
        let superstiçãoCaixa = Beat(soundEffectFileName: "snare_pozza.mp3", loop: [4, 12], bpm: 115, translation: superstiçãoTranslation, volume: 0.1)
        let superstiçãoBumbo = Beat(soundEffectFileName: "kick_pozzan.mp3", loop: [0, 6, 10], bpm: 115, translation: superstiçãoTranslation, volume: 0.4)

        let superstiçãoHighHat = Beat(soundEffectFileName: "hihat_pozzan.mp3", loop: [0, 4 , 8, 12], bpm: 115, translation: superstiçãoTranslation, volume: 0.15)
        
        let bass = AdditionalLayer(fileName: "superstição_baixo.mp3", volume: 0.8, delay: superstiçãoCaixa.eightNoteDuration * 3) // Aligned with the bumbo
        
        let guitarDelay = TimeInterval(superstiçãoCaixa.barDuration) * 2 + superstiçãoCaixa.eightNoteDuration * 3
        let primaryGuitar = AdditionalLayer(fileName: "superstição_guitarra_base.mp3", volume: 0.3, delay: guitarDelay)
        let secondaryGuitar = AdditionalLayer(fileName: "superstição_guitarras _secundarias.mp3", volume: 0.3, delay: guitarDelay)
        let vocals = AdditionalLayer(fileName: "superstição_voz.mp3", volume: 0.15, delay: guitarDelay)
        
        let additionalLayers = [0: [bass], 1: [primaryGuitar, secondaryGuitar], 2: [vocals]]
        // TODO: Implement a system that supports customised timing of additional layers
        
        return Song(beats: [superstiçãoCaixa, superstiçãoBumbo, superstiçãoHighHat], additionalLayers: additionalLayers)
    }

    static func velhoHabito() -> Song {
        let velhoHabitoTranslation = 3
        
        let velhoHabitoCaixa = Beat(soundEffectFileName: "snare_pozza.mp3", loop: [4, 7, 12], bpm: 100, translation: velhoHabitoTranslation, volume: 0.07)
        let velhoHabitoBumbo = Beat(soundEffectFileName: "kick_pozzan.mp3", loop: [0, 2, 6, 8, 10, 14], bpm: 100, translation: velhoHabitoTranslation, volume: 0.10)
        let velhoHabitoHighHat1 = Beat(soundEffectFileName: "hihat_pozzan.mp3", loop: [2,6,10,14], bpm: 100, translation: velhoHabitoTranslation, volume: 0.08)
        let velhoHabitoHighHat2 = Beat(soundEffectFileName: "hihat_pozzan.mp3", loop: [0,4,8,12], bpm: 100, translation: velhoHabitoTranslation, volume: 0.08)
        
        let primaryGuitar = AdditionalLayer(fileName: "guitarrabase_e_sintetizador.mp3", volume: 0.13, delay: 1.0)
        let secondaryGuitar = AdditionalLayer(fileName: "guitarrasolo_e_baixo.mp3", volume: 0.13, delay: 1.0)

        let additionalLayers = [0: [primaryGuitar], 1: [secondaryGuitar]]

        return Song(beats: [velhoHabitoCaixa, velhoHabitoBumbo, velhoHabitoHighHat1, velhoHabitoHighHat2], additionalLayers: additionalLayers)
    }

    
    
}
