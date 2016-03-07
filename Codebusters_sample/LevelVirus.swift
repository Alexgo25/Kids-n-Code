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
    
    init(levelcfg : LevelConfiguration , track : RobotTrack) {
        let rand = Int(arc4random() % 2)
        if (rand == 0) {
            virusType = VirusType.Blue
        }
        else {
            virusType = VirusType.Red
        }
        let texture = SKTexture(imageNamed: "Virus_\(virusType!.rawValue)")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        getPosition(levelcfg)
        zPosition = CGFloat(6 * floorPosition!.rawValue)
        self.track = track
        track.virus = self
        track.viruses.append(self)
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
        let move = SKAction.moveByX(0, y: -250, duration: 0.3)
        let group = SKAction.group([move , SKAction.fadeOutWithDuration(0.6) , animateTextures() , SKAction.removeFromParent()])
        
        return SKAction.runBlock({
            self.runAction(group)
        })
    }
    
    func animateTextures() -> SKAction {
        var textures : [SKTexture] = []
        let atlas = SKTextureAtlas(named: "VirusAnimations_\(virusType!.rawValue)")
        for textureName in atlas.textureNames {
            textures.append(SKTexture(imageNamed: textureName))
        }
        let action = SKAction.animateWithTextures(textures, timePerFrame: 0.06)
        return action
    }
    
}
