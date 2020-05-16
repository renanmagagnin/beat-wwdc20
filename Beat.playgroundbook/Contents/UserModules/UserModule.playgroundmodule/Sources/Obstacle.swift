//
//  Obstacle.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 06/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class Obstacle: SKSpriteNode {
    static let textureName: String = "Obstacle"
    static let glowTextureName: String = "ObstacleGlow"
    static let width: CGFloat = 15
    static let height: CGFloat = 40
    
    var width: CGFloat = Obstacle.width
    var height: CGFloat = Obstacle.height
    
    init() {
        let size = CGSize.init(width: Obstacle.width, height: Obstacle.height)
        let texture = SKTexture(imageNamed: Obstacle.textureName)
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = -1
        
        setupGlow()
        
        // Physics
        let physicsBody = SKPhysicsBody(rectangleOf: .init(width: size.width * 0.4, height: size.height * 0.6))
        physicsBody.categoryBitMask = PhysicsCategory.Obstacle
        physicsBody.contactTestBitMask = PhysicsCategory.All
        physicsBody.collisionBitMask = PhysicsCategory.None
        physicsBody.isDynamic = false
        physicsBody.usesPreciseCollisionDetection = true
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: Setup
extension Obstacle {
    func setupGlow() {
        let glow = SKSpriteNode(texture: .init(imageNamed: Obstacle.glowTextureName), size: .init(width: size.width * 2, height: size.height * 1.4))
        glow.zPosition = -1
        addChild(glow)
    }
}

// MARK: Animation
extension Obstacle {
    func hide() {
        let destionation = (position.vector() / 2.0).point()
        run(.move(to: destionation, duration: 0.15))
    }
    
    func show() {
        let destionation = (position.vector() * 2.0).point()
        run(.move(to: destionation, duration: 0.15))
    }
    
    func impactAnimation() {
        // Shrink and back
        let shrink = SKAction.scale(to: 0.6, duration: 0.1)
        let reset = SKAction.scale(to: 1, duration: 0.1)
        let resizing = SKAction.sequence([shrink, reset])
        
        // Clockwise rotation and back
        let rotationAngle = -CGFloat.pi/25
        let rotate = SKAction.rotate(byAngle: rotationAngle, duration: 0.1)
        let rotateBack = SKAction.rotate(byAngle: -rotationAngle, duration: 0.1)
        let rotation = SKAction.sequence([rotate, rotateBack])
        
        run(.group([resizing, rotation]))
    }
}
