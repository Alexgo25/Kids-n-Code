//
//  SceneTemplate.swift
//  Kids'n'Code
//
//  Created by Владислав Кутейников on 26.12.15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

class SceneTemplate: SKScene, ButtonNodeResponderType  {
    var overlay: SKSpriteNode? {
        didSet {
            if let overlay = overlay {
                overlay.removeFromParent()
                
                addChild(overlay)
                overlay.alpha = 0.0
                overlay.runAction(SKAction.fadeInWithDuration(0.2))
            }
        
            oldValue?.runAction(SKAction.fadeOutWithDuration(0.25)) {
                oldValue?.removeFromParent()
            }
        }
    }
    
    weak var sceneManager: SceneManager!
    
    override init() {
        super.init(size: CGSize(width: 2048, height: 1536))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed(button: ButtonNode) {
        
    }
    
}
