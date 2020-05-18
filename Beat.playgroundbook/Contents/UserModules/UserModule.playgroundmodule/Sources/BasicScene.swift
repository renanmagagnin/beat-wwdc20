//
//  Constants.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 09/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

struct ZPosition {
    static let Background            : CGFloat = 0
    static let Obstacle              : CGFloat = 100
    static let Planet                : CGFloat = 200
    static let Dinosaur              : CGFloat = 300
    static let Particle              : CGFloat = 400
    static let UserInterface         : CGFloat = 500
}

struct PhysicsCategory {
    static let None            : UInt32 = 0
    static let All             : UInt32 = UInt32.max
    static let Planet          : UInt32 = 0b1
    static let Dinosaur        : UInt32 = 0b10
    static let Obstacle        : UInt32 = 0b10
}

public class BasicScene: SKScene {
    
    var song: Song!
    var planets: [Planet] = []
    var selectedPlanet: Planet?
    var selectedPlanetIndex: Int = -1
    var nextPlanet: Planet? {
        let nextIndex = selectedPlanetIndex + 1
        if (0..<planets.count).contains(nextIndex) {
            return planets[nextIndex]
        } else {
            return nil
        }
    }
    
    // Appearance
    static let backgroundTextureName: String = "PurpleBackground"
    var backgroundNode: SKSpriteNode!
    
    
    var lastUpdateTime: TimeInterval = 0

    // PlanetDelegate
    var waitingPlanets: [Planet] = []
    var waitingAdditionalLayers: [AdditionalLayer] = []
    
    var completionWaitDuration: TimeInterval = 5
    
    override public func sceneDidLoad() {
        super.sceneDidLoad()
        
        setupBackground()
        setupStars()
        
        // Get rid of the lag on the first play
        AudioManager.shared.playAudio(named: "bassArticMonkeys.m4a", volume: 0.0)
        
        physicsWorld.contactDelegate = self
    }
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        let maximumDelta = 0.25 // This makes sure the game is paused when in background
        
        // Update entities
        if dt <= maximumDelta {
            for planet in planets {
                planet.update(deltaTime: dt)
            }
        }
        
        
        self.lastUpdateTime = currentTime
    }
    
    func setupBackground() {
        let texture = SKTexture(imageNamed: BasicScene.backgroundTextureName)
        backgroundNode = SKSpriteNode(texture: texture, color: .clear, size: size)
        backgroundNode.zPosition = ZPosition.Background
        addChild(backgroundNode)
    }
    
    func setupPlanets() {}
    
    func selectNextPlanet() {
        guard let selectedPlanet = self.selectedPlanet else { self.selectedPlanet = planets.first; self.selectedPlanetIndex = 0; self.selectedPlanet?.activate(); return }
        
        // If we have both, do transition animation
        if let nextPlanet = self.nextPlanet {
            
            animateTransferBetween(originPlanet: selectedPlanet, destinationPlanet: nextPlanet) {
                self.selectedPlanet = nextPlanet
                self.selectedPlanetIndex += 1
                nextPlanet.activate()
            }
        } else {
            print("Song is complete")
            
            let wait = SKAction.wait(forDuration: completionWaitDuration)
            let animateOut = SKAction.run {
                AudioManager.shared.reset()
                let transitionToNewSong = {
                    self.destroyAllPlanets()
                }
                self.animatePlanetsOut(completion: transitionToNewSong)
            }
            let wait2 = SKAction.wait(forDuration: 3)
            let transition = SKAction.run {
                self.setupPlanets()
            }
            self.run(.sequence([wait, animateOut, wait2, transition]))
        }
    }
}

// MARK: Transition
extension BasicScene {
    func transitionToEnding() {
        if let view = self.view {
            let scene = EndingScene(size: size)
            scene.scaleMode = .aspectFit
            scene.anchorPoint = .init(x: 0.5, y: 0.5)
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            //            view.showsPhysics = true
            //            view.showsFPS = true
            //            view.showsNodeCount = true
        }
    }
}

// MARK: PlanetDelegate
extension BasicScene: PlanetDelegate {
    
    func didFinishActivating(_ sender: Planet) {
        if sender == planets[0] {
            sender.startRecording()
        } else {
            waitingPlanets.append(sender)
        }
    }
    
    func didFinishRecording(_ sender: Planet) {
        if sender == planets[0] {
            sender.startPlaying()
        } else {
            waitingPlanets.append(sender)
        }
        
        // Enqueue new additional layers
        if let additionalLayerFileNames = self.song.additionalLayers[self.selectedPlanetIndex] {
            let waitDuration = 1.5
            let startPlayingAdditionalLayers = SKAction.run {
                self.waitingAdditionalLayers.append(contentsOf: additionalLayerFileNames)
            }
            self.run(.sequence([.wait(forDuration: waitDuration), startPlayingAdditionalLayers]))
        }
        
        selectNextPlanet()
    }
    
    func didStartPlayingCycle(_ sender: Planet) {
        
        // Handle any waiting planets
        for waitingPlanet in waitingPlanets {
            switch waitingPlanet.state {
            case .active:
                waitingPlanet.startRecording()
            case .recording:
                if waitingPlanet.isFinishedRecording {
                    waitingPlanet.startPlaying()
                } else {
                    waitingPlanet.restartRecording()
                }
            default:
                break
            }
        }
        waitingPlanets = []
        
        // Play and dequeue any waiting additional layers
        for layer in waitingAdditionalLayers {
            let delay = SKAction.wait(forDuration: layer.delay)
            let play = SKAction.run({ AudioManager.shared.playAudio(named: layer.fileName, volume: layer.volume, shouldLoop: layer.shouldLoop) })
            self.run(.sequence([delay, play]))
        }
        waitingAdditionalLayers = []
    }
    
}



// MARK: Entities
extension BasicScene {
    
    func createPlanet(beat: Beat, numberOfCycles: Int = 1, at position: CGPoint) {
        let planet = Planet(beat: beat, numberOfCycles: numberOfCycles)
        planet.position = position
        planet.delegate = self
        planets.append(planet)
        addChild(planet)
    }
    
    func destroyPlanet(_ planet: Planet) {
        if let index = planets.firstIndex(of: planet) {
            planets.remove(at: index)
        }
        planet.removeFromParent()
    }
    
    func destroyAllPlanets() {
        for planet in planets {
            destroyPlanet(planet)
        }
    }
    
    func animatePlanetsIn(completion: @escaping () -> Void = {}) {
        let scalingDuration: TimeInterval = 1
        for planet in planets {
            planet.setScale(0.01)
            let scale = SKAction.scale(to: 1, duration: scalingDuration)
            scale.timingMode = .easeOut
            
            planet.run(scale)
        }
        let wait = SKAction.wait(forDuration: scalingDuration)
        self.run(.sequence([wait, .run({ completion() })]))
    }
    
    func animatePlanetsOut(completion: @escaping () -> Void = {}) {
        let shrinkingDuration: TimeInterval = 1
        for planet in planets {
            planet.deactivate()
            
            let scale = SKAction.scale(to: 0, duration: shrinkingDuration)
            scale.timingMode = .easeIn
            planet.run(scale)
        }
        let wait = SKAction.wait(forDuration: shrinkingDuration)
        self.run(.sequence([wait, .run({ completion() })]))
    }

}

// MARK: SKPhysicsContactDelegate
extension BasicScene: SKPhysicsContactDelegate {
    
    public func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // First is lower bit mask
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if let dinosaur = firstBody.node as? Dinosaur, let obstacle = secondBody.node as? Obstacle {
            
            // Sound effect
            let playSoundAction = SKAction.playSoundFileNamed("HitObstacle", waitForCompletion: false)
            run(playSoundAction)
            
            obstacle.impactAnimation()
            
            let planet = dinosaur.planet
            planet.removeDinosaur()
            
            respawnAnimation(planet: dinosaur.planet) {
                if planet == self.planets[0] {
                    planet.restartRecording()
                } else {
                    self.waitingPlanets.append(planet)
                }
            }
            
            
        }
        
    }
    
}


// MARK: Touch Input
extension BasicScene {
    
    @objc func touchDown(atPoint pos : CGPoint) {
        if let selectedPlanet = self.selectedPlanet, selectedPlanet.state == .recording {
            selectedPlanet.play()
        }
    }
    
    @objc func touchMoved(toPoint pos : CGPoint) {}
    
    @objc func touchUp(atPoint pos : CGPoint) {}
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
}


// MARK: Animations
extension BasicScene {
    
    func spiritAnimation(from origin: CGPoint, to destination: CGPoint, completion: @escaping () -> Void) {
        if let emitter = spiritEmitter() {
            emitter.position = origin
            
            let moveAction = SKAction.move(to: destination, duration: 1.5)
            emitter.run(moveAction) {
                emitter.particleBirthRate = 0
                emitter.run(.sequence([.wait(forDuration: TimeInterval(emitter.particleLifetime)), .removeFromParent()]))
                completion()
            }
        }
        
        if let emitter = SKEmitterNode(fileNamed: "Trace.sks") {
            emitter.particleZPosition = ZPosition.Particle
            emitter.particlePositionRange = CGVector(dx: 8, dy: 20)
            emitter.particleSize = CGSize(width: 50, height: 30)
            emitter.position = origin
            emitter.targetNode = self
            emitter.particleRotation = (destination - origin).radians() - CGFloat.pi/2
            addChild(emitter)
            
            let moveAction = SKAction.move(to: destination, duration: 1.5)
            emitter.run(moveAction) {
                emitter.particleBirthRate = 0
                emitter.run(.sequence([.wait(forDuration: TimeInterval(emitter.particleLifetime)), .removeFromParent()]))
            }
        }
    }
    
    
    func animateTransferBetween(originPlanet: Planet, destinationPlanet: Planet, completion: @escaping () -> Void) {
        
        // Calculation of origin and destination positions
        let origin = originPlanet.position + CGVector(dx: 0, dy: originPlanet.radius + Dinosaur.size.height/2)
        let destination = destinationPlanet.position + CGVector(dx: 0, dy: destinationPlanet.radius + Dinosaur.size.height/2)
        
        // Performing of animation, calling completion
        if self.nextPlanet != nil {
            spiritAnimation(from: origin, to: destination) {
                completion()
            }
        }
    }
    
    func respawnAnimation(planet: Planet, completion: @escaping () -> Void) {
        // Get death position from recordedArcAngle
        let startPosition = planet.position + CGVector.vector(forAngle: -planet.recordedArcAngle + CGFloat.pi/2) * (planet.radius + Dinosaur.size.height/2)
        let endPosition = planet.position + CGVector(dx: 0, dy: planet.radius + Dinosaur.size.height/2)
        
        spiritAnimation(from: startPosition, to: endPosition) {
            completion()
        }
    }
    
}

extension BasicScene {
    func spiritEmitter() -> SKEmitterNode? {
        if let emitter = SKEmitterNode(fileNamed: "Spirit.sks") {
            emitter.particleZPosition = ZPosition.Particle
            emitter.targetNode = self
            addChild(emitter)
            
            return emitter
        } else {
            return nil
        }
        
    }
}

// MARK: Background
extension BasicScene {
    func setupStars() {
        if let foregroundParticleEmitter = SKEmitterNode(fileNamed: "ForegroundStars.sks") {
            foregroundParticleEmitter.particlePositionRange = CGVector(dx: self.frame.size.width, dy: self.frame.size.height)
            foregroundParticleEmitter.zPosition = ZPosition.Background + 1
            foregroundParticleEmitter.targetNode = self
            self.addChild(foregroundParticleEmitter)
        }

        if let backgroundParticleEmitter = SKEmitterNode(fileNamed: "BackgroundStars.sks") {
            backgroundParticleEmitter.particlePositionRange = CGVector(dx: self.frame.size.width, dy: self.frame.size.height)
            backgroundParticleEmitter.zPosition = ZPosition.Background + 1
            backgroundParticleEmitter.targetNode = self
            self.addChild(backgroundParticleEmitter)
        }
    }
    
    // This doesn't work. effect is only applied to children nodes.
    func setupBlur() {
        let blurNode = SKEffectNode()
        blurNode.zPosition = ZPosition.Background + 2
        blurNode.shouldEnableEffects = true
        if let blur = CIFilter(name: "CIGaussianBlur") {
            blur.setValue(0.5, forKey: kCIInputRadiusKey)
            blurNode.filter = blur
        }
        addChild(blurNode)
    }
}
