//
//  ActionButton.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 05.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

let kStepButtonLabel = NSLocalizedString("STEP_BUTTON_LABEL", comment: "Step button label")
let kTurnButtonLabel = NSLocalizedString("TURN_BUTTON_LABEL", comment: "Turn button label")
let kPushButtonLabel = NSLocalizedString("PUSH_BUTTON_LABEL", comment: "Push button label")
let kJumpButtonLabel = NSLocalizedString("JUMP_BUTTON_LABEL", comment: "Jump button label")
let kCatchButtonLabel = NSLocalizedString("CATCH_BUTTON_LABEL", comment: "Catch button label")

enum ActionType: String {
    case Move,
    Turn,
    Push,
    Jump,
    Catch,
    None
    
    func ActionButtonPosition() -> CGPoint {
        switch self {
        case .Move: return CGPoint(x: -215, y: 156)
        case .Turn: return CGPoint(x: -120, y: 250)
        case .Push: return CGPoint(x: 120, y: 250)
        case .Jump: return CGPoint(x: 215, y: 156)
        case .Catch: return CGPoint(x: 0, y: 292)
        default: return CGPoint.zero
        }
    }
}

class ActionButton: SKSpriteNode {
    
    var actionType: ActionType = .None
    private let label = SKLabelNode(fontNamed: "Ubuntu Bold")
    private let atlas = SKTextureAtlas(named: "ActionButtons")
    
    
    init(type: ActionType) {
        let texture = atlas.textureNamed("ActionButton_\(type)")
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        actionType = type
        position = CGPoint(x: 20, y: 60)
        userInteractionEnabled = true
        setScale(1)
        showLabel()
        name = "ActionButton_\(type)"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tapBegan()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        tapEnded()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {                    tapEnded()
        for touch in touches {
            weak var parent = self.parent
            if (parent != nil) {
                    let touchLocation = touch.locationInNode(parent!)
                    parent = nil
                    if containsPoint(touchLocation) {
                        TouchesAnalytics.sharedInstance.appendTouch(name!)
                        ActionCell.appendCell(actionType)
                        AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
                    }
            }
            
        }
        
    }
    
    func tapBegan() {
        texture = atlas.textureNamed("ActionButton_\(actionType)_Highlighted")
        runAction(SKAction.scaleTo(1.12, duration: 0.1))
        label.runAction(SKAction.scaleTo(0.9, duration: 0.1))
    }
    
    func tapEnded() {
        runAction(SKAction.scaleTo(1, duration: 0.1))
        label.runAction(SKAction.scaleTo(1, duration: 0.1))
        texture = atlas.textureNamed("ActionButton_\(actionType)")
    }
    
    func showButton() {
        let position = actionType.ActionButtonPosition()
        let move = SKAction.moveTo(position, duration: 0.1)
        runAction(move)
    }

    func hideButton(duration: NSTimeInterval = 0.1) {
        let move = SKAction.moveTo(CGPoint(x: 20, y: 60), duration: duration)
        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        runAction(sequence)
    }
//markLabels
    func showLabel() {
        switch actionType {
        case .Move:
            label.text = kStepButtonLabel
            label.position = CGPoint(x: -8, y: 75)
            zPosition = 11
        case .Turn:
            label.text = kTurnButtonLabel
            label.position = CGPoint(x: -35, y: 75)
            zPosition = 10
        case .Push:
            label.text = kPushButtonLabel
            label.position = CGPoint(x: 8, y: 75)
            zPosition = 10
        case .Jump:
            label.text = kJumpButtonLabel
            label.position = CGPoint(x: 15, y: 75)
            zPosition = 11
        case .Catch:
            label.text = kCatchButtonLabel
            label.position = CGPoint(x: 0, y: 75)
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
    
    static let Button_MovePosition = CGPoint(x: -188, y: 156)
    static let Button_TurnPosition = CGPoint(x: -61, y: 224)
    static let Button_PushPosition = CGPoint(x: 94, y: 224)
    static let Button_JumpPosition = CGPoint(x: 215, y: 156)
    
    
    
    
    
}
