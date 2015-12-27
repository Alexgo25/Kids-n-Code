//
//  ButtonType.swift
//  Kids'n'Code
//
//  Created by Владислав Кутейников on 25.12.15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

protocol ButtonNodeResponderType: class {
    func buttonPressed(button: ButtonNode)
}

class ButtonNode: SKSpriteNode {
    var responder: ButtonNodeResponderType {
        guard let responder = scene as? ButtonNodeResponderType else { fatalError() }
        return responder
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        userInteractionEnabled = true
    }
    
    func buttonPressed() {
        if userInteractionEnabled {
            responder.buttonPressed(self)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    
        if containsTouches(touches) {
            buttonPressed()
        }
    }
    
    func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = parent else { fatalError() }
        
        return touches.contains { touch in
            let touchLocation = touch.locationInNode(scene)
            let touchedNode = scene.nodeAtPoint(touchLocation)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}