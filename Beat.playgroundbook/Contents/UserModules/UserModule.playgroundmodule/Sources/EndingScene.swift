//
//  EndingScene.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 13/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class EndingScene: BasicScene {
    var thankYouNode: SKSpriteNode = SKSpriteNode()
    
    override public func sceneDidLoad() {
        super.sceneDidLoad()
        setupThankYou()
        
        // Animate UI at the centre
        animateIn {
            // Wait for a bit, move thank you node upwards and spawn inactive planets. Then, initatiate progressive activation of planets.
            let wait = SKAction.wait(forDuration: 1)
            self.run(wait) {
                let move = SKAction.move(to: .init(x: 0, y: self.size.height/4), duration: 1)
                move.timingMode = .easeInEaseOut
                self.thankYouNode.run(move)
                self.run(wait) {
                    self.setupPlanets()
                }
            }
            
        }
        
        // After a while, stop playing, remove planets and move thank you node back to centre.
        run(.sequence([.wait(forDuration: 37), .run({
            self.animatePlanetsOut()
            AudioManager.shared.reset()
            let move = SKAction.move(to: .zero, duration: 1.5)
            move.timingMode = .easeInEaseOut
            self.thankYouNode.run(move)
        })]))
    }
    
    override func setupPlanets() {
        self.selectedPlanet = nil
          
        // Create inactive planets in their correct positions
        setupVelhoHabito()
        
        let barDuration = TimeInterval(self.planets[0].beat.barDuration)
        
        // Animate planets in, and:
        // 1. Immediately start playing first planet. (Bumbo)
        // 2. After 3 bars, start playing the second planet and primary guitar. (Caixa)
        // 2. Then, after 2 more bars, start playing the third, fourth planet and secondary guitar. (High Hats)
        animatePlanetsIn() {
            self.planets[0].startPlaying()
            
            let caixaWait = (barDuration * 3.0)
            self.run(.sequence([.wait(forDuration: caixaWait - 0.2), .run({
                self.waitingAdditionalLayers.append(contentsOf: self.song.additionalLayers[0]!)
                self.waitingPlanets.append(self.planets[1])
            })]))
            
            let highHatWait = caixaWait + (barDuration * 2.0)
            self.run(.sequence([.wait(forDuration: highHatWait - 0.2), .run({
                self.waitingAdditionalLayers.append(contentsOf: self.song.additionalLayers[1]!)
                self.waitingPlanets.append(self.planets[2])
                self.waitingPlanets.append(self.planets[3])
            })]))
        }
    }
    
    // MARK: Planet Delegate
    override func didPlay(_ sender: Planet) {
        if sender == self.planets[0] {
            let growAction = SKAction.scale(to: 1.2, duration: 0.15)
            let goBackToNormalAction = SKAction.scale(to: 1, duration: 0.15)
            thankYouNode.run(.sequence([growAction, goBackToNormalAction]))
        }
    }
}

// MARK: Planets
extension EndingScene {
        func setupVelhoHabito() {
            self.song = Song.velhoHabito()
            
            let velhoHabitoBumbo = self.song.beats[0]
            createPlanet(beat: velhoHabitoBumbo, numberOfCycles: 1, at: CGPoint(x: -size.width/4, y: size.height/4))

            let velhoHabitoCaixa = self.song.beats[1]
            createPlanet(beat: velhoHabitoCaixa, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: size.height/4))

            let velhoHabitoHighHat1 = self.song.beats[2]
            createPlanet(beat: velhoHabitoHighHat1, numberOfCycles: 1, at: CGPoint(x: -size.width/4, y: -size.height/4))
            
            let velhoHabitoHighHat2 = self.song.beats[3]
            createPlanet(beat: velhoHabitoHighHat2, numberOfCycles: 1, at: CGPoint(x: size.width/4, y: -size.height/4))
            
            
            // Position Planets
            let planetRadius: CGFloat = planets[0].radius
            let planetWidth: CGFloat = planets[0].radius * 2
            let horizontalSpacing: CGFloat = planetWidth/5.0
            let horizontalDistance: CGFloat = planetWidth/5.0 + planetWidth
            
            let middleY: CGFloat = -size.height/5
            let verticalTranslation = planetRadius/2
            
            planets[0].position = .init(x: horizontalSpacing + planetRadius, y: middleY + verticalTranslation)
            for i in 1...3 {
                let x = planets[0].position.x + (CGFloat(i) * horizontalDistance)
                let y = (i % 2 == 0) ? middleY + verticalTranslation : middleY - verticalTranslation
                planets[i].position = .init(x: x, y: y)
            }
            
            for p in planets {
                p.position.x -= size.width/2
            }
            
            
            // Create letters
            let letters = ["W", "W", "D", "C"]
            for i in 0..<4 {
                if let planetBody = self.planets[i].bright {
                    let letterNode = SKSpriteNode(imageNamed: letters[i])
                    letterNode.size = letterNode.size * 0.7
                    letterNode.zPosition = planetBody.zPosition + 1
                    planetBody.addChild(letterNode)
                }
            }
        }
}


// MARK: Setup
extension EndingScene {
    func setupThankYou() {
        thankYouNode = SKSpriteNode(imageNamed: "ThankYou")
        thankYouNode.zPosition = ZPosition.UserInterface
        addChild(thankYouNode)
    }
}

// MARK: Animation
extension EndingScene {
    func animateIn(completion: @escaping () -> Void) {
        thankYouNode.setScale(0)
        let scaleUpAction = SKAction.scale(to: 1, duration: 0.4)
        thankYouNode.run(.sequence([.wait(forDuration: 1), scaleUpAction])) {
            completion()
        }
    }
    
    func animateOut(completion: @escaping () -> Void) {
        let scaleDownAction = SKAction.scale(to: 0, duration: 0.5)
        thankYouNode.run(scaleDownAction) {
            completion()
        }
    }
}
