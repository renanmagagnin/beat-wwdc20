//
//  Dinosaur.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 06/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

enum MovementDirection {
    case clockwise, counterClockwise
}

public class Dinosaur: SKSpriteNode {
    static let size = CGSize(width: 25, height: 25)
    static let textureName: String = "Character"
    static let movementSpeed: CGFloat = 300
    static let jumpTime: TimeInterval = 0.35 // 0.25 // 0.5
    static let jumpHeight: CGFloat = 4.5
    
    var planet: Planet
    
    // Movement
    var positionAngle: CGFloat = CGFloat.pi/2
    var positionRadius: CGFloat
    var angularSpeed: CGFloat
    
    var movementDirection: MovementDirection = .clockwise
    
    // Jump
    var remainingJumpTime: TimeInterval = 0.0
    var canJump: Bool {
        return remainingJumpTime == 0.0
    }
    
    // Particle
    var traceEmitter: SKEmitterNode!
    
    init(planet: Planet) {
        self.planet = planet
        self.positionRadius = planet.radius + Dinosaur.size.height/2
        self.angularSpeed = Dinosaur.movementSpeed / self.positionRadius
        super.init(texture: SKTexture(imageNamed: Dinosaur.textureName), color: .clear, size: Dinosaur.size)
        self.zPosition = ZPosition.Dinosaur
        
        setupTrace()
        
        updatePosition()
        
        // Physics
        let physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody.categoryBitMask = PhysicsCategory.Dinosaur
        physicsBody.contactTestBitMask = PhysicsCategory.All
        physicsBody.collisionBitMask = PhysicsCategory.None
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: TimeInterval) {        
        updateJump(deltaTime: deltaTime)
        move(deltaTime: deltaTime)
        updatePosition()
    }

}

// MARK: Setup
extension Dinosaur {
    
    func setupTrace() {
        if let emitter = SKEmitterNode(fileNamed: "Trace.sks") {
            emitter.particleZPosition = ZPosition.Particle
            emitter.targetNode = self.planet.delegate as! GameScene
            emitter.position.x = -size.width/2.5
            addChild(emitter)
            traceEmitter = emitter
        }
    }
    
}

// MARK: Jumping
extension Dinosaur {
    func jump() {
        if canJump {
            remainingJumpTime = Dinosaur.jumpTime
            
            // Animate
            let totalDuration = Dinosaur.jumpTime
            let risingStretch = SKAction.group([.scaleY(to: 2, duration: totalDuration/8), .scaleX(to: 0.7, duration: totalDuration/8)])
            let squash = SKAction.group([.scaleY(to: 0.5, duration: totalDuration/4), .scaleX(to: 1.3, duration: totalDuration/4)])
            let fallingStretch = SKAction.group([.scaleY(to: 2, duration: totalDuration/2), .scaleX(to: 0.7, duration: totalDuration/2)])
            let reset = SKAction.scale(to: 1, duration: totalDuration/4)
            run(.sequence([risingStretch, squash, fallingStretch, squash, reset]))
        }
    }
    
    
    func updateJump(deltaTime: TimeInterval) {
        if remainingJumpTime >= 0.0 {
            let jumpTime = CGFloat(Dinosaur.jumpTime)

            // Parabola parameters
            let x: CGFloat = jumpTime - CGFloat(remainingJumpTime)
            let a: CGFloat = -4 * (Dinosaur.jumpHeight - 1) / (jumpTime * jumpTime)
            let b: CGFloat = -a * jumpTime
            let c: CGFloat = 1
            let h: CGFloat = x * (a * x + b) + c
            
            let newRadius = planet.radius + (Dinosaur.size.height * h - Dinosaur.size.height/2)
            
            remainingJumpTime -= deltaTime
            remainingJumpTime = max(0.0, remainingJumpTime)

            positionRadius = newRadius
        }
    }
}


// MARK: Movement
extension Dinosaur {
    func updatePosition() {
        // Draw dinosaur to it's position
        let direction = CGVector.vector(forAngle: positionAngle)
        let positionVector = direction * positionRadius
        self.position = .zero + positionVector
        
        // Rotate dinosaur
        zRotation = positionAngle - CGFloat.pi/2 // not exactly sure why
        
        traceEmitter.particleRotation = zRotation - CGFloat.pi/2
    }
    
    func move(deltaTime: TimeInterval) {
        // Make sure
        if action(forKey: "stretching") == nil {
            self.run(.scaleX(to: 1.15, duration: Dinosaur.jumpTime/4), withKey: "stretching")
        }
        
        // Increment angle according to it's angular speed and movement direction
        switch movementDirection {
        case .clockwise:
            positionAngle -= angularSpeed * CGFloat(deltaTime)
        case .counterClockwise:
            positionAngle += angularSpeed * CGFloat(deltaTime)
        }
    }
}
