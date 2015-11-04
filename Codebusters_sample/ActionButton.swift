//
//  ActionButton.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 05.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class ActionButton: SKSpriteNode {

    private var actionType: ActionType = .none
    private let label = SKLabelNode(fontNamed: "Ubuntu Bold")
    private let atlas = SKTextureAtlas(named: "ActionButtons")
    
    
    init(type: ActionType) {
        let texture = atlas.textureNamed("ActionButton_\(type.rawValue)")
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        actionType = type
        position = CGPoint(x: 20, y: 60)
        userInteractionEnabled = true
        setScale(1)
        showLabel()
        name = "ActionButton_\(type.rawValue)"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tapBegan()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        tapEnded()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {                    tapEnded()
        for touch in touches {
            let touchLocation = touch.locationInNode(parent!)
            if containsPoint(touchLocation) {
                TouchesAnalytics.sharedInstance.appendTouch(name!)
                ActionCell.appendCell(actionType)
                AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
                
            }
        }
    }
    
    func getActionType() -> ActionType {
        return actionType
    }
    
    func tapBegan() {
        texture = atlas.textureNamed("ActionButton_\(actionType.rawValue)_Highlighted")
        runAction(SKAction.scaleTo(1.12, duration: 0.1))
        label.runAction(SKAction.scaleTo(0.9, duration: 0.1))
    }
    
    func tapEnded() {
        runAction(SKAction.scaleTo(1, duration: 0.1))
        label.runAction(SKAction.scaleTo(1, duration: 0.1))
        texture = atlas.textureNamed("ActionButton_\(actionType.rawValue)")
    }
    
    func showButton() {
        let move = SKAction.moveTo(getActionButtonPosition(actionType), duration: 0.1)
        runAction(move)
    }

    func hideButton(duration: NSTimeInterval = 0.1) {
        let move = SKAction.moveTo(CGPoint(x: 20, y: 60), duration: duration)
        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        runAction(sequence)
    }
    
    func showLabel() {
        switch actionType {
        case .move:
            label.text = "ШАГНУТЬ"
            label.position = CGPoint(x: -8, y: 75)
            zPosition = 11
        case .turn:
            label.text = "ПОВЕРНУТЬСЯ"
            label.position = CGPoint(x: -35, y: 75)
            zPosition = 10
        case .push:
            label.text = "ТОЛКНУТЬ"
            label.position = CGPoint(x: 8, y: 75)
            zPosition = 10
        case .jump:
            label.text = "ПРЫГНУТЬ"
            label.position = CGPoint(x: 15, y: 75)
            zPosition = 11
        default:
            label.text = ""
        }
        
        label.fontSize = 23
        label.fontColor = UIColor.blackColor()
        label.verticalAlignmentMode = .Center
        
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
