//
//  Robot.swift
//  Codebusters_sample
//
//  Created by Alexander on 01.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction {
    case ToRight,
    ToLeft
}

class Robot: SKSpriteNode {
    
    var actions: [SKAction] = []
    var direction: Direction = .ToRight
    
    func moveForward() {
        let animation = SKAction.animateWithTextures(MoveAnimationTextures(direction), timePerFrame: 0.04)
        let repeatAnimation = SKAction.repeatAction(animation, count: 5)
        //let moveToAction = SKAction.moveTo(getNextPosition(direction), duration: 1.6)
        
        let action = SKAction.group([repeatAnimation])
        actions.append(action)
    }
    
    func turn() {
        let animation = SKAction.animateWithTextures(TurnAnimationTextures(direction), timePerFrame: 0.1)
        let action = SKAction.runBlock({
            self.runAction(animation)
            self.changeDirection()
        })
        actions.append(action)
    }
    
    func jump() -> SKAction {
        return SKAction()
    }
    
    func push() -> SKAction {
        return SKAction()
    }
    
    func moveToStart() {
        position = Constants.Robot_StartPosition
    }
    
    func getStartPosition() -> CGPoint {
        return Constants.Robot_StartPosition
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override convenience init() {
        let color = UIColor()
        let texture = SKTexture(imageNamed: "robot")
        let size = Constants.Robot_Size
        self.init(texture: texture, color: color, size: size)
        moveToStart()
    }
    
    func getNextPosition(direction: Direction) -> CGPoint {
        var position = self.position
        if direction == .ToRight {
            position.x += CGFloat(236 / 225 * size.width)
        } else {
            position.x -= CGFloat(236 / 225 * size.width)
        }
        
        return position
    }
    
    func changeDirection() {
        if direction == .ToRight {
            direction = .ToLeft
        } else {
            direction = .ToRight
        }
    }
}
