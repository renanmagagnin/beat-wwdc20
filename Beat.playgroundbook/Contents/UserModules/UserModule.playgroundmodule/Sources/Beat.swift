//
//  Beat.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 09/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import CoreGraphics
import Foundation

struct Beat {
    var soundEffectFileName: String
    var volume: Float = 1
    
    // Information about when the sound effect should be played.
    var loop: [Int]         // All indexes assume a bar is divided into 16 equal parts(eighth notes).
    
    let bpm: Int
    
    let barDuration: CGFloat
    let numberOfBars: Int
    var period: CGFloat {
        return CGFloat(numberOfBars) * barDuration
    }
    
    var eightNoteDuration: TimeInterval {
        return TimeInterval(barDuration)/16.0
    }
    
    init(soundEffectFileName: String, loop: [Int], bpm: Int, beatsPerBar: Int = 4, translation: Int = 0, volume: Float = 1) {
        self.soundEffectFileName = soundEffectFileName
        self.volume = volume
        self.bpm = bpm
        
        self.barDuration = CGFloat(beatsPerBar) / (CGFloat(bpm)/60)
        
        if let lastNote = loop.last {
            self.numberOfBars = max(1, Int(ceil(CGFloat(lastNote)/16.0)))  // Max() to support the edge case where there is only a note at index 0
        } else {
            self.numberOfBars = 0
        }
        
        self.loop = loop
        // Apply translation to loop, if necessary
        if translation != 0 {
            self.loop = self.loop.map { start -> Int in
                var newStart = (start + translation) % (self.numberOfBars * 16)
                
                if newStart < 0 {
                    newStart = self.numberOfBars * 16 - (newStart % self.numberOfBars * 16) - 1
                }
                
                return newStart
            }
        }
        self.loop.sort()
    }
}
