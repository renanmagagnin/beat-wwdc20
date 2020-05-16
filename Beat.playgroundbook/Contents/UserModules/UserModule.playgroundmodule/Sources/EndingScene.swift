//
//  EndingScene.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 13/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class EndingScene: SKScene {
    
    static let backgroundTextureName: String = "PurpleBackground"
    var backgroundNode: SKSpriteNode = SKSpriteNode()
    
    // Thank you for playing, credits?
    
    // Play a dope song with planets, one layer at a time. Pop and start playing.
    
    override public func sceneDidLoad() {
        super.sceneDidLoad()
        setupBackground()
        setupStars()
    }
}


// MARK: Setup
extension EndingScene {
    func setupBackground() {
        let texture = SKTexture(imageNamed: BasicScene.backgroundTextureName)
        backgroundNode = SKSpriteNode(texture: texture, color: .clear, size: size)
        backgroundNode.zPosition = ZPosition.Background
        addChild(backgroundNode)
    }
    
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
}
