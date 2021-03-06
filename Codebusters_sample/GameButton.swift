//
//  GameButton.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 21.07.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

enum GameButtonType: String {
    case Pause,
    Tips,
    Debug,
    Clear,
    Start,
    Restart,
    Restart_PauseView,
    Continue_PauseView,
    Exit_PauseView,
    Exit_EndLevelView,
    Restart_EndLevelView,
    NextLevel_EndLevelView,
    Ok
    
    func getPosition() -> CGPoint {
        switch self {
        case .Clear: return CGPoint(x: 1908, y: 229)
        case .Debug: return CGPoint(x: 1612, y: 229)
        case .Pause: return CGPoint(x:103, y: 1440)
        case .Start: return CGPoint(x: 1760, y: 120)
        case .Tips, .Ok: return CGPoint(x: 237, y: 1440)
        case .Restart: return CGPoint(x: 1760, y: 324)
        case .Restart_PauseView: return CGPoint(x: 306, y: 950)
        case .Continue_PauseView: return CGPoint(x: 306, y: 1094)
        case .Exit_PauseView: return CGPoint(x: 306, y: 806)
        case .NextLevel_EndLevelView: return CGPoint(x: 1363, y: 581.5)
        case .Restart_EndLevelView: return CGPoint(x: 1018.5, y: 581.5)
        case .Exit_EndLevelView: return CGPoint(x: 672, y: 581.5)
        }
    }
}

class GameButton: ButtonNode {
    let gameButtonType: GameButtonType
    
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
        position = type.getPosition()
        zPosition = 1002
        
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
        
        userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouched = true
        AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouched = false
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouched = false
        super.touchesCancelled(touches, withEvent: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}