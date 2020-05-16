//
//  Extensions.swift
//  WWDC2020
//
//  Created by Renan Magagnin on 06/05/20.
//  Copyright © 2020 Renan Magagnin. All rights reserved.
//

import SpriteKit

// MARK: SKShapeNode
extension SKShapeNode {
    // Used for ability button cooldown animation
    static func arcShapeNodeWith(_ radius: CGFloat, _ startingAngle: CGFloat, _ endingAngle: CGFloat, clockwise: Bool) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint.zero,
                    radius: radius,
                    startAngle: startingAngle + CGFloat.pi/2,
                    endAngle: endingAngle + CGFloat.pi/2,
                    clockwise: clockwise)
        
        let mask = SKShapeNode(path: path)
        mask.lineWidth = 1
        mask.fillColor = .blue
        mask.strokeColor = .white
        return mask
    }
}

// MARK: - Double
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

// MARK: - CGSize
extension CGSize {
    // Operations between CGSize and CGFloat
    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }
}


// MARK: - CGVector
extension CGVector {
    
    static func vector(forAngle angle: CGFloat) -> CGVector {
        return CGVector(dx: cos(angle), dy: sin(angle)).normalized()
    }
    
    func point() -> CGPoint {
        return CGPoint.zero + self
    }

    func length() -> CGFloat {
        return sqrt(self.dx * self.dx + self.dy * self.dy)
    }
    
    func radians() -> CGFloat {
        return atan2(self.dy, self.dx)
    }
    
    func normalized() -> CGVector {
        return CGVector(dx: dx / length(), dy: dy / length())
    }
    
    func rotatedBy(angle: CGFloat) -> CGVector {
        let newDX = cos(angle) * self.dx - sin(angle) * self.dy
        let newDY = sin(angle) * self.dx + cos(angle) * self.dy
        return CGVector(dx: newDX, dy: newDY)
    }
    
    func perpendicularClockwise() -> CGVector {
        return CGVector(dx: -self.dy, dy: self.dx)
    }
    
    func perpendicularCounterClockwise() -> CGVector {
        return CGVector(dx: self.dy, dy: -self.dx)
    }
    
    
    
    // Operations between CGVector and CGFloat
    static func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(dx: left.dx * right, dy: left.dy * right)
    }
    
    static func / (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(dx: left.dx / right, dy: left.dy / right)
    }
    
    static func *= (left: inout CGVector, right: CGFloat) {
        left = left * right
    }
    
    static func /= (left: inout CGVector, right: CGFloat) {
        left = left / right
    }
}

// MARK: - CGPoint
extension CGPoint {
    
    func vector() -> CGVector {
        return CGVector(dx: self.x, dy: self.y)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        let distance = (self - point).length()
        return distance
    }
    
    func rotatedBy(angle: CGFloat) -> CGPoint {
        let newX = cos(angle) * self.x - sin(angle) * self.y
        let newY = sin(angle) * self.x + cos(angle) * self.y
        return CGPoint(x: newX, y: newY)
    }
    
    // Operations between CGPoint and CGPoint
    static func - (left: CGPoint, right: CGPoint) -> CGVector {
        return CGVector(dx: left.x - right.x, dy: left.y - right.y)
    }
    
    // Operations between CGPoint and CGVector
    static func + (left: CGPoint, right: CGVector) -> CGPoint {
        return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
    }
    
    static func - (left: CGPoint, right: CGVector) -> CGPoint {
        return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
    }
    
    static func += (left: inout CGPoint, right: CGVector) {
        left = left + right
    }

    static func -= (left: inout CGPoint, right: CGVector) {
        left = left - right
    }

}
