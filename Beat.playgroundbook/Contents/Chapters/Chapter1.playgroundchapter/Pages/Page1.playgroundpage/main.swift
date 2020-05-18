/*:
 
 - Important:
 Welcome! Start by reading the instructions below.
 
 ----
 
 ## Instructions
 ![The player moving towards an obstacle.](Instructions.png)
 - Tap anywhere to make the moving player **jump**.
 - **Avoid obstacles** to complete a cycle.
 - Make sure to have **sound on** and play on **full screen mode**.
 - Tap "Run My Code" and have fun!!
 
 ----
 
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

