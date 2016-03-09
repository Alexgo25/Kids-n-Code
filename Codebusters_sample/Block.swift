//
//  Block.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 13.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

class Block: SKSpriteNode {
    static let BlockStartPosition = CGPoint(x: 168, y: 389)
    static let BlockFaceSize = CGSize(width: 204, height: 203)
    
    private var floorPosition: FloorPosition
    private var trackPosition: Int
    
    private let blockFace: SKSpriteNode
    private let blockUpper: SKSpriteNode
    private let blockRight: SKSpriteNode
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(trackPosition: Int, floorPosition: FloorPosition) {
        let atlas = SKTextureAtlas(named: "Block")
        blockFace = SKSpriteNode(texture: atlas.textureNamed("Block_Face"))
        blockUpper = SKSpriteNode(texture: atlas.textureNamed("Block_Upper"))
        blockRight = SKSpriteNode(texture: atlas.textureNamed("Block_Right"))
      
        self.trackPosition = trackPosition
        self.floorPosition = floorPosition
        
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSize())
        anchorPoint = CGPointZero
        position = getCurrentPosition()
        addChild(blockFace)
        addChild(blockRight)
        addChild(blockUpper)

        blockFace.zPosition = CGFloat( floorPosition.rawValue  + 101)
        blockUpper.zPosition = CGFloat( floorPosition.rawValue + 100)
        blockRight.zPosition = CGFloat( Double(floorPosition.rawValue) + 99.5)

        blockFace.anchorPoint = CGPointZero
        blockRight.anchorPoint = CGPointZero
        blockUpper.anchorPoint = CGPointZero
        
        blockUpper.position = CGPoint(x: 0, y: 203)
        blockRight.position = CGPoint(x: 204, y: 0)
    }
    
    func moveToNextPosition(direction: Direction, floorPosition: FloorPosition) -> SKAction {
        let moveByX = SKAction.moveTo(getNextPosition(direction), duration: 0.5)
        let moveByY = SKAction.moveTo(getNextPosition(direction, floorPosition: floorPosition), duration: 0.15)
        let sequence: SKAction
        
        let setBlockRightZPosition = SKAction.runBlock() {
            self.blockRight.zPosition = CGFloat(Double(floorPosition.rawValue) + 99.5) //8
        }

        let setFullBlockZPosition = SKAction.runBlock() {
            self.blockFace.zPosition = CGFloat( floorPosition.rawValue + 101)  //10
            self.blockUpper.zPosition = CGFloat(floorPosition.rawValue + 100)  //9
        }
        
        if self.floorPosition.rawValue > floorPosition.rawValue {
            let sound = SKAction.runBlock() {
                AudioPlayer.sharedInstance.playSoundEffect("CubeFalling.mp3")
            }
            sequence = SKAction.sequence([moveByX, setBlockRightZPosition, sound, moveByY, setFullBlockZPosition])
        } else {
            sequence = SKAction.sequence([moveByX, moveByY])
        }
        self.floorPosition = floorPosition
        trackPosition += direction.rawValue
        
        return SKAction.runBlock( {
            self.runAction(sequence)
        } )
    }
    
    func getPosition(trackPosition: Int, floorPosition: FloorPosition) -> CGPoint {
        let X = Block.BlockStartPosition.x + CGFloat(trackPosition - 1) * Block.BlockFaceSize.width
        let Y = Block.BlockStartPosition.y + CGFloat(floorPosition.rawValue - 1) * Block.BlockFaceSize.height
        return CGPoint(x: X, y: Y)
    }
    
    func getCurrentPosition() -> CGPoint {
        return getPosition(trackPosition, floorPosition: floorPosition)
    }
    
    func getNextPosition(direction: Direction) -> CGPoint {
        return getPosition(trackPosition + direction.rawValue, floorPosition: floorPosition)
    }
    
    func getNextPosition(direction: Direction, floorPosition: FloorPosition) -> CGPoint {
        return getPosition(trackPosition + direction.rawValue, floorPosition: floorPosition)
    }
}