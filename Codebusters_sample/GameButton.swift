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
    
    private let gameButtonType: GameButtonType
    private let atlas = SKTextureAtlas(named: "GameButtons")
    
    init(type: GameButtonType) {
        let texture = atlas.textureNamed("GameButton_\(type.rawValue)")
        gameButtonType = type
        super.init(texture: texture, color: UIColor(), size: texture.size())
        position = getGameButtonPosition(type)
        zPosition = 1001
        
        userInteractionEnabled = true
        name = "GameButton_\(type.rawValue)"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touched()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(parent!)
            if containsPoint(touchLocation) {
                parent!.touchesEnded(touches, withEvent: event)
            }
            resetTexture()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resetTexture()
    }
    
    func touched() {
        AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
        texture = atlas.textureNamed("GameButton_\(gameButtonType.rawValue)_Pressed")
    }
    
    func resetTexture() {
        texture = atlas.textureNamed("GameButton_\(gameButtonType.rawValue)")
    }
    
    func getActionType() -> GameButtonType {
        return gameButtonType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}