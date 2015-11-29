//
//  GameButton.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 21.07.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

enum GameButtonType: String {
    case Pause = "Pause",
    Tips = "Tips",
    Debug = "Debug",
    Clear = "Clear",
    Start = "Start",
    Restart = "Restart",
    Restart_PauseView = "Restart_PauseView",
    Continue_PauseView = "Continue_PauseView",
    Exit_PauseView = "Exit_PauseView",
    Exit_EndLevelView = "Exit_EndLevelView",
    Restart_EndLevelView = "Restart_EndLevelView",
    NextLevel_EndLevelView = "NextLevel_EndLevelView",
    Ok = "Ok"
}

class GameButton: SKSpriteNode {
    private var background: SKSpriteNode
    private let gameButtonType: GameButtonType
    
    init(type: GameButtonType) {
        let atlas = SKTextureAtlas(named: "GameButtons")
        let texture = atlas.textureNamed("GameButton_\(type.rawValue)")
        background = SKSpriteNode(texture: texture)
        background.zPosition = -2
        
        gameButtonType = type
        
        super.init(texture: nil, color: UIColor(), size: CGSize())
        position = getGameButtonPosition(type)
        zPosition = 1003
        
        userInteractionEnabled = true
        name = "GameButton_\(type.rawValue)"
        
        addChild(background)
        
        switch gameButtonType {
        case .Continue_PauseView:
            let label = createLabel("ПРОДОЛЖИТЬ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero)
            label.zPosition = -1
            addChild(label)
        case .Exit_PauseView:
            let label = createLabel("ВЫЙТИ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero)
            label.zPosition = -1
            addChild(label)
        case .Restart_PauseView:
            let label = createLabel("ЗАНОВО", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero)
            label.zPosition = -1
            addChild(label)
        default:
            break
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touched()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            weak var parent = self.parent
            let touchLocation = touch.locationInNode(parent!)
            if containsPoint(touchLocation) {
                parent!.touchesEnded(touches, withEvent: event)
            }
            parent = nil
            resetTexture()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resetTexture()
    }
    
    func touched() {
        AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
        let atlas = SKTextureAtlas(named: "GameButtons")
        let texture = atlas.textureNamed("GameButton_\(gameButtonType.rawValue)_Pressed")
        background.texture = texture
    }
    
    func resetTexture() {
        let atlas = SKTextureAtlas(named: "GameButtons")
        let texture = atlas.textureNamed("GameButton_\(gameButtonType.rawValue)")
        background.texture = texture
    }
    
    func getActionType() -> GameButtonType {
        return gameButtonType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}