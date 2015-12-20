//
//  GameButton.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 21.07.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

protocol GameButtonNodeResponderType: class {
    func buttonPressed(button: GameButton)
}

enum GameButtonType: String {
    case Pause
    case Tips
    case Debug
    case Clear
    case Start
    case Restart
    case Restart_PauseView
    case Continue_PauseView
    case Exit_PauseView
    case Exit_EndLevelView
    case Restart_EndLevelView
    case NextLevel_EndLevelView
    case Ok
}

class GameButton: SKSpriteNode {
    let gameButtonType: GameButtonType
    
    var responder: GameButtonNodeResponderType {
        guard let responder = parent as? GameButtonNodeResponderType else { fatalError() }
        return responder
    }
    
    var isTouched = false {
        didSet {
            guard oldValue != isTouched else { return }

            let textureString = isTouched ? "GameButton_\(gameButtonType)_Pressed" : "GameButton_\(gameButtonType)"
            let texture = SKTexture(imageNamed: textureString)
            let action = SKAction.setTexture(texture)
            runAction(action)
        }
    }
    
    init(type: GameButtonType) {
        let atlas = SKTextureAtlas(named: "GameButtons")
        let texture = atlas.textureNamed("GameButton_\(type)")
        
        gameButtonType = type
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        position = getGameButtonPosition(type)
        zPosition = 1002
        
        userInteractionEnabled = true
        
        name = "GameButton_\(type.rawValue)"

        guard gameButtonType == .Continue_PauseView || gameButtonType == .Exit_PauseView || gameButtonType == .Restart_PauseView else { return }
        
        let label = createLabel("", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero)
        
        switch gameButtonType {
        case .Continue_PauseView:
            label.text = "ПРОДОЛЖИТЬ"
        case .Exit_PauseView:
            label.text = "ВЫЙТИ"
        case .Restart_PauseView:
            label.text = "ЗАНОВО"
        default:
            break
        }
    
        addChild(label)
    }
    
    func buttonPressed() {
        if userInteractionEnabled {
            responder.buttonPressed(self)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        isTouched = true
        AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        isTouched = false
        if containsTouches(touches) {
            buttonPressed()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
    }
    
    func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = parent else { fatalError() }
        
        return touches.contains { touch in
            let touchLocation = touch.locationInNode(scene)
            let touchedNode = scene.nodeAtPoint(touchLocation)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
    }
    
    func getActionType() -> GameButtonType {
        return gameButtonType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}