//
//  Block.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 13.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

class Block: SKNode {
   
    private var floorPosition: FloorPosition = .ground
    private var trackPosition: Int = 0
    private static let atlas = SKTextureAtlas(named: "Block")

    private let blockFace = SKSpriteNode(texture: atlas.textureNamed("Block_Face"))
    private let blockUpper = SKSpriteNode(texture: atlas.textureNamed("Block_Upper"))
    private let blockRight = SKSpriteNode(texture: atlas.textureNamed("Block_Right"))
    private let blockRightDown = SKSpriteNode(texture: atlas.textureNamed("Block_Right_Down"))
    private let blockUpperLeft = SKSpriteNode(texture: atlas.textureNamed("Block_Upper_Left"))
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(trackPosition: Int, floorPosition: FloorPosition) {
        super.init()
        self.trackPosition = trackPosition
        self.floorPosition = floorPosition
        position = CGPoint(x: getXBlockPosition(trackPosition), y: getYBlockPosition(floorPosition))
        zPosition = 99
        addChild(blockFace)
        addChild(blockRight)
        addChild(blockUpper)
        addChild(blockRightDown)
        addChild(blockUpperLeft)
        
        blockUpperLeft.zPosition = 0
        blockRight.zPosition = 0
        blockFace.zPosition = 3
        blockRightDown.zPosition = 1
        
        blockUpperLeft.position = CGPoint(x: -102, y: 100.5)
        blockFace.position = CGPoint(x: -56.5, y: -30.5)
        blockUpper.position = CGPoint(x: 0, y: 100.5)
        blockRight.position = CGPoint(x: 102, y: 0)
        blockRightDown.position = CGPoint(x: 102, y: -101.5)
    }
    
    func moveToNextPosition(direction: Direction, floorPosition: FloorPosition) -> SKAction {
        let moveByX = SKAction.moveTo(getNextPosition(direction), duration: 0.5)
        let moveByY = SKAction.moveTo(getNextPosition(direction, floorPosition: floorPosition), duration: 0.15)
        let sequence: SKAction
        if self.floorPosition.rawValue > floorPosition.rawValue {
            let sound = SKAction.runBlock() {
                AudioPlayer.sharedInstance.playSoundEffect("CubeFalling.mp3")
            }
            sequence = SKAction.sequence([moveByX, sound, moveByY])
        } else {
            sequence = SKAction.sequence([moveByX, moveByY])
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