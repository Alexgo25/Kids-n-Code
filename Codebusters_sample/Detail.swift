//
//  Detail.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 21.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit
import UIKit

enum DetailType: String {
    case Battery = "Battery",
    CPU = "CPU",
    Fan = "Fan",
    HardDrive = "HardDrive",
    RAM1 = "RAM1",
    RAM2 = "RAM2",
    Crystall = "Crystall"
}

class Detail: SKSpriteNode {
    private var detailType: DetailType
    private var trackPosition: Int
    private var floorPosition: FloorPosition
    private var atlas = SKTextureAtlas(named: "Details")
    
    init(detailType: DetailType, trackPosition: Int, floorPosition: FloorPosition) {
        let texture = atlas.textureNamed("Detail_\(detailType.rawValue)")
        self.detailType = detailType
        self.trackPosition = trackPosition
        self.floorPosition = floorPosition
        super.init(texture: texture, color: UIColor(), size: texture.size())
        position = getCGPointOfPosition(trackPosition, floorPosition: floorPosition)
        zPosition = 100
        if floorPosition == .first {
            position.y += 60
        } else {
            position.y += 180
        }
        
        if detailType == .Battery {
            setScale(0.6)
        }
        
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody!.categoryBitMask = PhysicsCategory.Detail
        physicsBody!.contactTestBitMask = PhysicsCategory.Robot
        physicsBody!.collisionBitMask = 0
        
        let moveUp = SKAction.moveByX(0, y: 90, duration: 1)
        let moveDown = SKAction.moveByX(0, y: -90, duration: 1)
        let sequence = SKAction.sequence([moveUp, moveDown])
        runAction(SKAction.repeatActionForever(sequence))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideDetail() {
        let fadeOut = SKAction.fadeOutWithDuration(0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        runAction(sequence)
        AudioPlayer.sharedInstance.playSoundEffect("DetailAchievement.wav")
    }
    
    func getDetailType() -> DetailType {
        return detailType
    }
    
    func getTrackPosition() -> Int {
        return trackPosition
    }
    
    func getFloorPosition() -> FloorPosition {
        return floorPosition
    }
}
