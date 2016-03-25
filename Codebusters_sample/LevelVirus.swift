//
//  LevelVirus.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

enum VirusType : String {
    case Red ,
    Blue
}

class LevelVirus : SKSpriteNode {
    
    private weak var track: RobotTrack?
    var floorPosition : FloorPosition?
    var trackPosition = 0
    var virusType : VirusType?

    init(track: RobotTrack , trackPosition : Int , floorPosition : FloorPosition) {
        let rand = Int(arc4random() % 2)
        if (rand == 0) {
            virusType = VirusType.Blue
        }
        else {
            virusType = VirusType.Red
        }
        let texture = SKTexture(imageNamed: "Virus_\(virusType!.rawValue)")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = CGFloat(floorPosition.rawValue + 102)
        self.floorPosition = floorPosition
        self.trackPosition = trackPosition
        let X = FirstBlockPosition.x + CGFloat(trackPosition - 1) * Block.BlockFaceSize.width
        let dY = (floorPosition.rawValue - 1) * 203
        let Y : CGFloat = CGFloat(704 + dY)
        self.position = CGPoint(x: X, y: Y)
        self.track = track
        track.viruses.append(self)
        let texture2 = SKTexture(imageNamed: "Virus1_\(virusType!.rawValue)")
        let textures = [texture , texture2]
        let repeatAction = SKAction.animateWithTextures(textures, timePerFrame: 0.01, resize: false, restore: false)
        self.runAction(SKAction.repeatActionForever(repeatAction))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition(levelcfg : LevelConfiguration) {
        let X = FirstBlockPosition.x + CGFloat(levelcfg.virusPosition - 1) * Block.BlockFaceSize.width
        let dY = (levelcfg.virusFloorPosition.rawValue - 1) * 203
        let Y: CGFloat = CGFloat(734 + dY)
        self.position = CGPoint(x: X, y: Y)
        trackPosition = levelcfg.virusPosition
        floorPosition = levelcfg.virusFloorPosition
    }
    
    func fadeOut() -> SKAction {
        let fadeOut = SKAction.fadeOutWithDuration(0.3)
        let resize = SKAction.scaleTo(0.145, duration: 0.3)
        let seq = SKAction.group([fadeOut , resize])
        return SKAction.runBlock({
            self.runAction(seq)
        })
    }

    
}
