//
//  MenuScene.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 13/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class MenuScene: SKScene {
    static let backgroundTextureName: String = "PurpleBackground"
    var backgroundNode: SKSpriteNode = SKSpriteNode()
    
    var logo: SKSpriteNode = SKSpriteNode()
    var tapToStart: SKSpriteNode = SKSpriteNode()
    
    var isReady = false
    
    public override func sceneDidLoad() {
        super.sceneDidLoad()

        setupBackground()
        setupStars()

        setupLogo()
        setupTapToStart()

        animateIn() {
            self.isReady = true
        }
    }
}

//// MARK: User Interaction
extension MenuScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isReady {
            // Sound effect
            AudioManager.shared.playAudio(named: "MenuSelect.wav")
            
            animateOut {
                self.transitionToGame()
            }
        }
    }
}

// MARK: Transition
extension MenuScene {
    func transitionToGame() {
        if let view = self.view {
            let scene = GameScene(size: size)
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

// MARK: Setup
extension MenuScene {
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
    
    func setupLogo() {
        logo = SKSpriteNode(imageNamed: "Logo")
        logo.zPosition = ZPosition.UserInterface
        addChild(logo)
//        logo.setScale(0)
//
//        let waitAction = SKAction.wait(forDuration: 0.5)
//        let scaleUpAction = SKAction.scale(to: 1, duration: 0.5)
//        logo.run(.sequence([waitAction, scaleUpAction])) {
//            completion()
//        }
    }
    
    func setupTapToStart() {
        tapToStart = SKSpriteNode(imageNamed: "TapToStart")
        tapToStart.position.y = -size.height/4
        tapToStart.zPosition = ZPosition.UserInterface
        addChild(tapToStart)
    }
}

// MARK: Animation
extension MenuScene {
    func animateIn(completion: @escaping () -> Void) {
        
        logo.setScale(0)
        let scaleUpAction = SKAction.scale(to: 1, duration: 0.5)
        logo.run(.sequence([.wait(forDuration: 1), scaleUpAction]))
        
        
        tapToStart.alpha = 0
        let fadeOutAction = SKAction.fadeOut(withDuration: 1.2)
        let fadeInAction = SKAction.fadeIn(withDuration: 1)
        let blinkAction = SKAction.repeatForever(.sequence([fadeOutAction, fadeInAction]))
        
        tapToStart.run(.sequence([.wait(forDuration: 3), fadeInAction])) {
            self.tapToStart.run(blinkAction)
            completion()
        }
    }
    
    func animateOut(completion: @escaping () -> Void) {
        let shrinkAction = SKAction.scale(to: 0.7, duration: 0.15)
        let growAction = SKAction.scale(to: 1.2, duration: 0.15)
        let goBackToNormalAction = SKAction.scale(to: 1, duration: 0.15)
        
        if logo.action(forKey: "animateOut") == nil {
            logo.run(.sequence([shrinkAction, growAction, goBackToNormalAction]), withKey: "animateOut")
            tapToStart.run(.sequence([.fadeOut(withDuration: 0.45)])) {
                completion()
            }
        }
    }
}
