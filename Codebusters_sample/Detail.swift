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
    case Battery, CPU,
    Fan, HardDrive,
    RAM1, RAM2,
    Crystall,
    Door
    
    func getDetailCellPosition() -> CGPoint {
        switch self {
        case .Battery: return CGPoint(x: 1194, y: 1001)
        case .HardDrive: return CGPoint(x: 1070, y: 732)
        case .RAM1: return CGPoint(x: 1351, y: 663)
        case .RAM2: return CGPoint(x: 1649, y: 663)
        case .CPU: return CGPoint(x: 1510, y: 815)
        case .Fan: return CGPoint(x: 1668, y: 993)
        default: return CGPoint.zero
        }
    }
}

class Detail: SKSpriteNode {
    let FirstBlockPosition = CGPoint(x: 315, y: 760)
    
    var detailType = DetailType.Crystall
    private var startPosition = CGPointZero
    private weak var track: RobotTrack?
    
    init(track: RobotTrack, levelInfo: LevelConfiguration) {
        self.track = track
        
        detailType = levelInfo.detailType
        
        let atlas = SKTextureAtlas(named: "Details")
        let texture = atlas.textureNamed("Detail_\(detailType)")
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        let floorPosition = getFloorPosition()
        position = getPosition()
        if !(track.getFloorPositionAt(getTrackPosition()).rawValue < floorPosition.rawValue) {
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
            let moveUp = SKAction.moveTo(startPosition, duration: 1)
            let moveDown = SKAction.moveByX(0, y: -100, duration: 1)
            let sequence = SKAction.sequence([moveDown, moveUp])
            runAction(SKAction.repeatActionForever(sequence))
        }
    }
    
    func fixPosition() {
        removeAllActions()
        let time: NSTimeInterval = Double((startPosition.y - position.y)/60 * 0.7)
        runAction(SKAction.moveTo(startPosition, duration: time))
    }
    
    func getTrackPosition() -> Int {
        return track!.detailPosition
    }
    
    func getFloorPosition() -> FloorPosition {
        return track!.detailFloorPosition
    }
    
    func getPosition() -> CGPoint {
        let X = FirstBlockPosition.x + CGFloat(getTrackPosition() - 1) * Block.BlockFaceSize.width
        let Y: CGFloat = getFloorPosition() == .First ? 734 : 937
        return CGPoint(x: X, y: Y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
