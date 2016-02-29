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
    
    init() {
        let texture = SKTexture(imageNamed: "Virus")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
