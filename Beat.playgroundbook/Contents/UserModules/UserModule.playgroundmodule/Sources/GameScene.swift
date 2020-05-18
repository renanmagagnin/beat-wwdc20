//
//  GameScene.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 05/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit
import GameplayKit

// Planet completion animation
// Respawn animation

// Lag the first time



public class GameScene: BasicScene {
    
    var currentSong = 0
    
    override public func sceneDidLoad() {
        super.sceneDidLoad()
        
        setupPlanets()
    }
    
    
    override func setupPlanets() {
        self.selectedPlanet = nil
        
        switch self.currentSong {
        case 0:
            setupDoIWannaKnow()
        case 1:
            setupWeWillRockYou()
        case 2:
            setupSuperstição()
        default:
            transitionToEnding()
        }
        
        animatePlanetsIn {
            self.selectNextPlanet()
        }
        
        self.currentSong += 1
    }
    
}


// MARK: Setup Planets for a Song
extension GameScene {
    
    func setupDoIWannaKnow() {
        self.song = Song.doIWannaKnow()
        self.completionWaitDuration = 22
        
        let bass = self.song.beats[0]
        createPlanet(beat: bass, numberOfCycles: 1, at: CGPoint(x: -size.width/4, y: size.height/16))
        
        let bassAndSnare = self.song.beats[1]
        createPlanet(beat: bassAndSnare, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: -size.height/16))
    }
    
    func setupWeWillRockYou() {
        self.song = Song.weWillRockYou()
        self.completionWaitDuration = 21
        
        let weWillRockYouBass = self.song.beats[0]
        createPlanet(beat: weWillRockYouBass, numberOfCycles: 1, at: CGPoint(x: -size.width/4, y: -size.height/16))

        let weWillRockYouHat = self.song.beats[1]
        createPlanet(beat: weWillRockYouHat, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: size.height/16))
    }
    
    func setupSuperstição() {
        self.song = Song.superstição()
        self.completionWaitDuration = 25
        
        let superstiçãoCaixa = self.song.beats[0]
        createPlanet(beat: superstiçãoCaixa, numberOfCycles: 2, at: CGPoint(x: -size.width/6, y: size.height/10))
        
        let superstiçãoBumbo = self.song.beats[1]
        createPlanet(beat: superstiçãoBumbo, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: size.height/4))
        
        let superstiçãoHighHat = self.song.beats[2]
        createPlanet(beat: superstiçãoHighHat, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: -size.height/4))
    }
    
    func setupVelhoHabito() {
        self.song = Song.velhoHabito()
        
        let velhoHabitoBumbo = self.song.beats[0]
        createPlanet(beat: velhoHabitoBumbo, numberOfCycles: 1, at: CGPoint(x: -size.width/5, y: 0))

        let velhoHabitoCaixa = self.song.beats[1]
        createPlanet(beat: velhoHabitoCaixa, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: size.height/4))

//        let velhoHabitoHighHat = self.song.beats[2]
//        createPlanet(beat: velhoHabitoHighHat, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: -size.height/4))
    }
    
}
