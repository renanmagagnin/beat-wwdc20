/*:
 
 - Important:
 Start by reading the instructions and play on full screen mode. Have fun!!
 
 # Introduction
 ![A Player, his orbs and enemy player with his spikes.](Introduction.png)
 - A player's size represents his current health: the more health a player has, the bigger and slower he is.
 ----
 
 # Objective
 Survive through waves of enemy players, collect power ups and defeat The Boss.
 
 ----
 
 # Controls
 ![Analog stick and the abilities bar](Controls.png)
 You move the orange player using the analog stick and manipulate his orbs using the abilites bar.
 
 ----
 
 # Power Ups
 - **Instant:** Extra orbs or healing.
 - **Temporary:** Double damage, double orb regeneration or burst of speed.
 - **Upgrades:** More damage or faster orb regeneration.
 
 ----
 
 # Credits
 
 - SpriteKit Analog Stick by [MitrophD](https://github.com/MitrophD)
 - "Nice Kitty" by [Cimba](https://cimba.newgrounds.com/)
 
*/
 
//#-hidden-code

import SpriteKit
import PlaygroundSupport
import AVFoundation

// Constants
let viewSize =  UIScreen.main.bounds.size // CGSize(width: 1024, height: 768)

// Code to bring the game
let spriteView = SKView(frame: CGRect(origin: .init(x: 0, y: 0), size: viewSize))

// Debugging flags
//spriteView.showsDrawCount = true
//spriteView.showsNodeCount = true
//spriteView.showsPhysics = true
//spriteView.showsFPS = true



let scene = MenuScene(size: spriteView.frame.size)
scene.scaleMode = .aspectFit
scene.anchorPoint = .init(x: 0.5, y: 0.5)

spriteView.presentScene(scene)
spriteView.ignoresSiblingOrder = true

// Show in Playground live view
PlaygroundPage.current.liveView = spriteView

//#-end-hidden-code

