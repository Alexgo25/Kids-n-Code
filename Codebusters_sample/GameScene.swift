//
//  GameScene.swift
//  Codebusters_sample
//
//  Created by Alexander on 28.03.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

enum NodeType: UInt32 {
    case ActionButton = 1,
    ActionCell = 2,
    Touch = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background: SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        background = Background(blocksPattern: [.first, .second, .first, .first, .first], robotPosition: 1, detailType: .RAM, detailPosition: 5, detailFloorPosition: .first)
        addChild(background!)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
    /*func didBeginContact(contact: SKPhysicsContact) {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
    case NodeType.ActionButton.rawValue | NodeType.Touch.rawValue:
    var action = contact.bodyB.node as! ActionButton?
    action!.showLabel()
    default:
    return
    }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
    case NodeType.ActionButton.rawValue | NodeType.ActionCell.rawValue:
    var action = contact.bodyB.node as! ActionButton?
    action!.hideLabel()
    default:
    return
    }
    }*/
    

    /*override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touchesSet = touches as! Set<UITouch>
        for touch in touchesSet {
            var touchLocation = touch.locationInNode(self)
            
            var touchedNode = nodeAtPoint(touchLocation)
            var previousLocation = touch.previousLocationInNode(self)
            
            var translation = CGPointMake(touchLocation.x - previousLocation.x, touchLocation.y - previousLocation.y)
            
            panForTranslation(translation)
        }
    }
    
    func panForTranslation(translation: CGPoint) {
        var position = selectedNode!.position
        if (selectedNode?.isKindOfClass(ActionButton) != nil) {
            selectedNode!.position = CGPoint(x: selectedNode!.position.x + translation.x, y: selectedNode!.position.y + translation.y)
        }
    }*/
