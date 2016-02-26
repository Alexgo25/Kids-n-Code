//
//  LoopsMenuScene.swift
//  Kids'n'Code
//
//  Created by Alexander on 26/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import UIKit
import Google
import SpriteKit

class LoopsMenuScene: SceneTemplate {
    
    let background = SKSpriteNode(imageNamed: "loopsMenuBackground")
    
    
    override init() {
        super.init()
        addChild(background)
        background.anchorPoint = CGPointZero
        background.zPosition = -1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
    }

    
}

