//
//  Block.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 13.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

class Block: SKSpriteNode {
   
    private var floorPosition: FloorPosition = .ground
    private var trackPosition: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(trackPosition: Int, floorPosition: FloorPosition) {
        let texture = SKTexture(imageNamed: "block")
        super.init(texture: texture, color: UIColor(), size: texture.size())
        self.trackPosition = trackPosition
        self.floorPosition = floorPosition
        zPosition = CGFloat(trackPosition + 7 * (floorPosition.rawValue - 1))
        position = CGPoint(x: getXBlockPosition(trackPosition), y: getYBlockPosition(floorPosition))
    }
    
    func moveToNextPosition(direction: Direction, floorPosition: FloorPosition) -> SKAction {
        let moveByX = SKAction.moveTo(getNextPosition(direction), duration: 0.5)
        let moveByY = SKAction.moveTo(getNextPosition(direction, floorPosition: floorPosition), duration: 0.15)
        let sequence: SKAction
        let position = CGFloat(trackPosition + direction.rawValue + 7 * (floorPosition.rawValue - 1))
        let z = SKAction.runBlock( { self.zPosition = position } )
        
        if self.floorPosition.rawValue > floorPosition.rawValue {
            let sound = SKAction.playSoundFileNamed("CubeFalling.mp3", waitForCompletion: false)
            sequence = SKAction.sequence([moveByX, z, sound, moveByY])
        } else {
            sequence = SKAction.sequence([moveByX, z, moveByY])
        }
        self.floorPosition = floorPosition
        trackPosition += direction.rawValue
        
        return SKAction.runBlock( {
            self.runAction(sequence)
        } )
    }
    
    func getNextPosition(direction: Direction) -> CGPoint {
        return CGPoint(x: getXBlockPosition(trackPosition + direction.rawValue), y: getYBlockPosition(floorPosition))
    }
    
    func getNextPosition(direction: Direction, floorPosition: FloorPosition) -> CGPoint {
        return CGPoint(x: getXBlockPosition(trackPosition + direction.rawValue), y: getYBlockPosition(floorPosition))
    }
}