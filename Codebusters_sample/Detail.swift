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
    private var detailType = DetailType.Crystall
    private var trackPosition = 0
    private var floorPosition = FloorPosition.first
    private var startPosition: CGPoint?
    private weak var track: RobotTrack?
    
    init(track: RobotTrack) {
        self.track = track
        
        let levelData = GameProgress.sharedInstance.getCurrentLevelData()
        
        if let position = levelData["detailPosition"] as? Int {
            trackPosition = position
        }
        
        if let detailFloorPositionInt = levelData["detailFloorPosition"] as? Int {
            if let floor = FloorPosition(rawValue: detailFloorPositionInt) {
                floorPosition = floor
            }
        }
        
        if let detailTypeString  = levelData["detailType"] as? String {
            if let type = DetailType(rawValue: detailTypeString) {
                detailType = type
            }
        }
        
        let atlas = SKTextureAtlas(named: "Details")
        let texture = atlas.textureNamed("Detail_\(detailType.rawValue)")
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        position = getCGPointOfPosition(trackPosition, floorPosition: floorPosition)
        if !(track.getFloorPositionAt(trackPosition).rawValue < floorPosition.rawValue) {
            zPosition = CGFloat(6 * floorPosition.rawValue + 1)
        } else {
            zPosition = CGFloat(5 * (floorPosition.rawValue + 1))
        }
        position.y += 220
        startPosition = position
        
        if detailType == .Battery {
            setScale(0.6)
        }
        
        alpha = 1
        
        move()
        
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 50, height: 50))
        physicsBody!.categoryBitMask = PhysicsCategory.Detail
        physicsBody!.contactTestBitMask = PhysicsCategory.Robot
        physicsBody!.collisionBitMask = 0
        name = "Detail"
    }
    
    func hideDetail() {
        let fadeOut = SKAction.fadeOutWithDuration(0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        runAction(sequence)
        AudioPlayer.sharedInstance.playSoundEffect("DetailAchievement.wav")
    }
    
    func move() {
        if !hasActions() {
            let moveUp = SKAction.moveTo(startPosition!, duration: 1)
            let moveDown = SKAction.moveByX(0, y: -100, duration: 1)
            let sequence = SKAction.sequence([moveDown, moveUp])
            runAction(SKAction.repeatActionForever(sequence))
        }
    }
    
    func fixPosition() {
        removeAllActions()
        let time: NSTimeInterval = Double((startPosition!.y - position.y)/60 * 0.7)
        runAction(SKAction.moveTo(startPosition!, duration: time))
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
