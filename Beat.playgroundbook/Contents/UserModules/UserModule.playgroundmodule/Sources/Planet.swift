    //
//  Planet.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 05/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

protocol PlanetDelegate {
    var waitingPlanets: [Planet] { get set }
    var waitingAdditionalLayers: [AdditionalLayer] { get set }
    
    func didFinishActivating(_ sender: Planet)
    func didStartPlayingCycle(_ sender: Planet)
    func didFinishRecording(_ sender: Planet)
}


enum PlanetState {
    case inactive, active, recording, recorded
}

public class Planet: SKSpriteNode {
    
    var delegate: PlanetDelegate?
    var metronomeCount: TimeInterval = 0
    
    // Musical Information
    var beat: Beat
    var numberOfCycles: Int
    var period: TimeInterval  // Not necessarily the same as beat since there might be multiple cycles
    
    var cooldown: TimeInterval = 0.18
    var canPlay = true {
        didSet {
            if !canPlay {
                run(.sequence([.wait(forDuration: cooldown), .run({ self.canPlay = true })]))
            }
        }
    }
    
    // Phyisical Characteristics
    static let gravitationalStrength: CGFloat = 40
    var radius: CGFloat
    
    
    // Entities
    var dinosaur: Dinosaur?
    var obstacles: [Obstacle] = []
    var obstaclePositions: [Int] = []
    
    // State
    var state: PlanetState = .inactive
    var recordedArcAngle: CGFloat = 0 {
        didSet {
            updateBorder()
        }
    }
    var isActivating: Bool = false
    var isFinishedRecording: Bool {
        return recordedArcAngle >= 2 * CGFloat.pi
    }
    
    
    // Appearance
    static let textureName: String = "Planet"
    static let darkTextureName: String = "DarkPlanet"
    static let glowTextureName: String = "PlanetGlow"
    static let borderTextureName: String = "PlanetBorder"
    var bright: SKSpriteNode!
    
    var glow: SKSpriteNode!
    
    let borderCropNode = SKCropNode()
    var border: SKSpriteNode!
    
    
    init(beat: Beat, numberOfCycles: Int = 1) {
        self.beat = beat
        self.numberOfCycles = numberOfCycles
        self.period = TimeInterval(beat.period * CGFloat(numberOfCycles))
        self.radius = CGFloat(self.period) * Dinosaur.movementSpeed / (2 * CGFloat.pi) - Dinosaur.size.height/2
        
        let texture = SKTexture(imageNamed: Planet.darkTextureName)
        super.init(texture: texture, color: .clear, size: .init(width: radius * 2, height: radius * 2))
        self.zPosition = ZPosition.Planet
        
        setupBright()
        setupGlow()
        
        setupBorder()
        
        constructObstacles()
        
        // State
        deactivate()
        
        // Physics
        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody.categoryBitMask = PhysicsCategory.Planet
        physicsBody.contactTestBitMask = PhysicsCategory.All
        physicsBody.isDynamic = false
        physicsBody.usesPreciseCollisionDetection = true
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: TimeInterval) {
        
        // Update Metronome
        if state != .inactive {
            metronomeCount += deltaTime
            metronomeCount = metronomeCount.truncatingRemainder(dividingBy: TimeInterval(beat.period))
        }
        
        // Movement of Dinosaur (while updating recordedArcLength)
        switch state {
        case .recording:
            guard let dinosaur = dinosaur else { break }
            let previousPositionAngle = dinosaur.positionAngle
            dinosaur.update(deltaTime: deltaTime)
            
            let difference = abs(dinosaur.positionAngle - previousPositionAngle)
            recordedArcAngle += difference
            
            // Check if recording is complete
            if isFinishedRecording {
                removeDinosaur()
                explodeObstacles()
                
                delegate?.didFinishRecording(self)
            }
        case .recorded:
            // Detect when a cycle starts and call delegate fun
            if metronomeCount <= 0.02 { // Least amount of loss I could get to the syncing
                delegate?.didStartPlayingCycle(self)
            }
            
            // Check if it's time to play
            let numberOfSpotsPerLoop = beat.numberOfBars * 16
            let numberOfSpots = numberOfCycles * numberOfSpotsPerLoop
            
            let percentage = metronomeCount/period
            let currentArcIndex = Int(CGFloat(percentage) * CGFloat(numberOfSpots))
            if obstaclePositions.contains(currentArcIndex) {
                play()
                print(currentArcIndex)
            }
        default:
            break
        }
    }
    
    func updateBorder() {
        let borderAngle = min(recordedArcAngle, CGFloat.pi * 2)
        borderCropNode.maskNode = SKShapeNode.arcShapeNodeWith(size.width/2 * 1.1, 0.0, -borderAngle, clockwise: true)
    }
    
}
    
// MARK: Setup
extension Planet {
    
    func setupBright() {
        self.bright = SKSpriteNode(texture: .init(imageNamed: Planet.textureName), size: size)
        self.bright.zPosition = 1
        self.bright.alpha = 0
        addChild(self.bright)
    }
    
    func setupGlow() {
        self.glow = SKSpriteNode(texture: .init(imageNamed: Planet.glowTextureName), size: size * CGFloat(290.0/256.0) * 1.1)
        self.glow.zPosition = self.zPosition - 30 // what?
        self.glow.alpha = 0.13
        addChild(self.glow)
    }
    
    
    func setupBorder() {
        // Mask Node
        borderCropNode.zPosition = ZPosition.Planet + 1
        self.addChild(borderCropNode)

        // Border
        border = SKSpriteNode(texture: .init(imageNamed: Planet.borderTextureName), size: size)
        borderCropNode.addChild(border)
        
        updateBorder()
    }
    
}

// MARK: States
extension Planet {
    
    func deactivate() {
        state = .inactive
       
        let fadeOutDuration = 0.5
        bright.run(.fadeOut(withDuration: fadeOutDuration))
        border.run(.fadeOut(withDuration: fadeOutDuration))
        glow.run(.fadeOut(withDuration: fadeOutDuration))
        
        obstacles.forEach({$0.hide()})
    }
    
    func activate() {
        if isActivating { return }
        
        isActivating = true
        
        // Animation
        let fadeInDuration: TimeInterval = 1.0
        bright.run(.fadeIn(withDuration: fadeInDuration))
        border.run(.fadeIn(withDuration: fadeInDuration))
        glow.run(.fadeAlpha(to: 0.13, duration: fadeInDuration))
        
        obstacles.forEach({$0.show()})
        
        // Spawning animation
        
        
        let changeState = SKAction.run({
            self.state = .active
            self.spawnDinosaur()
            self.delegate?.didFinishActivating(self)
            self.isActivating = false
        })
        self.run(.sequence([changeState]))
    }
    
    func startRecording() {
        state = .recording
        recordedArcAngle = 0
        
        metronomeCount = 0
        
        // Sound Effect
        
        // Make sure to handle deaths by starting over
    }
    
    func restartRecording() {
        // Sound Effect
        recordedArcAngle = 0
        
        // Animate
            
        // Spawn dinosaur at start
        spawnDinosaur()
    }
    
    func startPlaying() {
        state = .recorded
        
        metronomeCount = 0
        
        // Sound Effect
        
        // Animate (Morph into recorded state)
        obstacles.forEach({$0.hide()}) // TODO: This should be replaced with explosion
    }
    
}

// MARK: Dinosaur
extension Planet {
    
    func spawnDinosaur(atAngle angle: CGFloat = 0) {
        removeDinosaur()
        
        let newDinosaur = Dinosaur(planet: self)
        dinosaur = newDinosaur
        addChild(newDinosaur)
        
        newDinosaur.planet = self
    }
    
    // Consider visually absorbing dinosaur
    func removeDinosaur() {
        if let dinosaur = dinosaur {
            dinosaur.removeFromParent()
            self.dinosaur = nil
        }
    }
    
}


// MARK: Obstacles
extension Planet {
    func constructObstacles() {
        let numberOfSpotsPerLoop = beat.numberOfBars * 16
        let numberOfSpots = numberOfCycles * numberOfSpotsPerLoop
        
        // Equally divide the circumference
        let spotArcLength = 2 * CGFloat.pi / CGFloat(numberOfSpots)
        
        for cycle in 0..<numberOfCycles {
            for noteStart in beat.loop {
                let noteStartIndex = cycle * numberOfSpotsPerLoop + noteStart
                obstaclePositions.append(noteStartIndex)
                let positionAngle = spotArcLength/2 + CGFloat(noteStartIndex) * spotArcLength
                addObstacle(atAngle: -positionAngle) // Negative since, by convention, angles will always be clockwise
            }
        }
    }
       
    func addObstacle(atAngle angle: CGFloat = 0) {
        let obstacle = Obstacle()
        obstacle.zRotation = angle
        obstacles.append(obstacle)
        addChild(obstacle)
        
        // Position obstacle on the planet's surface
        var position = CGVector(dx: 0, dy: radius + obstacle.size.height * 0.4)
        position = position.rotatedBy(angle: angle)
        
        obstacle.position = .zero + position
    }
    
    func explodeObstacles() {
        for obstacle in obstacles {
            if let emitter = SKEmitterNode(fileNamed: "ObstacleExplosion.sks") {
                emitter.targetNode = self
                emitter.position = obstacle.position
                emitter.particleZPosition = ZPosition.Particle
                addChild(emitter)
            }
            
            // Sound
//            AudioManager.shared.playAudio(named: "explosion.mp3", volume: 0.1, shouldLoop: false)
            
            
            obstacle.removeFromParent()
        }
        obstacles = []
    }

}


// MARK: Sound
extension Planet {
    func play() {
        if canPlay {
            playAnimation()

            AudioManager.shared.playAudio(named: beat.soundEffectFileName, volume: beat.volume)

            dinosaur?.jump()
            
            canPlay = false
        }
    }

}


// MARK: Visual Effects
extension Planet {
    
    func playAnimation() {
        // Animation
        let shrink = SKAction.scale(to: 0.8, duration: 0.05)
        shrink.timingMode = .easeInEaseOut
        let expand = SKAction.scale(to: 1.2, duration: 0.12)
        expand.timingMode = .easeInEaseOut
        let reset = SKAction.scale(to: 1, duration: 0.2)
        reset.timingMode = .easeInEaseOut
        
        

        // Splash animation if already recorded
        if state == .recorded, let scene = self.delegate as? BasicScene {
            if let emitter = SKEmitterNode(fileNamed: "Splash.sks") {
                emitter.targetNode = scene
                let scaleMultiplier = max(min((radius - 122)/(186 - 122), 1), 0) + 1
                emitter.particleScale *= scaleMultiplier
                emitter.position = self.position
                scene.addChild(emitter)
            }
            
            if let emitter = SKEmitterNode(fileNamed: "ThickSplash.sks") {
                emitter.targetNode = scene
                let scaleMultiplier = max(min((radius - 122)/(186 - 122), 0.8), 0) + 1 // 1 to 2
                emitter.particleScale *= scaleMultiplier
                emitter.position = self.position
                scene.addChild(emitter)
            }
        }
        
        
        // Shockwave
        let shockwave = SKSpriteNode(texture: .init(imageNamed: "Shockwave"), size: size)
        addChild(shockwave)
        
        let expand2 = SKAction.scale(to: 2, duration: 0.35)
        expand2.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        shockwave.run(.sequence([.wait(forDuration: 0.15), .group([expand2, fadeOut]), .removeFromParent()]))
        
        self.run(.sequence([shrink, expand, reset]))
    }
}

