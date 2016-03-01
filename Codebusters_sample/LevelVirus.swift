//
//  LevelVirus.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

class LevelVirus : SKSpriteNode {
    
    private weak var track: RobotTrack?
    
    init(levelcfg : LevelConfiguration , track : RobotTrack) {
        let texture = SKTexture(imageNamed: "Virus")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = 3001
        getPosition(levelcfg)
        self.track = track
        track.virus = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition(levelcfg : LevelConfiguration) {
        let X = FirstBlockPosition.x + CGFloat(levelcfg.virusPosition) * Block.BlockFaceSize.width
        let dY = (levelcfg.virusFloorPosition.rawValue - 1) * 203
        let Y: CGFloat = CGFloat(734 + dY)
        self.position = CGPoint(x: X, y: Y)
    }
    
}
