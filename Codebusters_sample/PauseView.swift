//
//  PauseView.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 15.05.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class PauseView: SKSpriteNode {
    
    private let backgroundRightPart = SKSpriteNode(imageNamed: "pauseBackgroundRightPart")
    private let backgroundLeftPart = SKSpriteNode(imageNamed: "pauseBackgroundLeftPart")
    
    private let buttonRestart = GameButton(type: .Restart_PauseView)
    private let buttonContinue = GameButton(type: .Continue_PauseView)
    private let buttonExit = GameButton(type: .Exit_PauseView)
    
    private let soundSwitcher = AudioPlayer.sharedInstance.soundsSwitcher
    private let musicSwitcher = AudioPlayer.sharedInstance.musicSwitcher
    
    
    init() {
        let texture = backgroundRightPart.texture!
        super.init(texture: texture, color: UIColor(), size: texture.size())
        zPosition = 2000
        backgroundRightPart.zPosition = 900
        backgroundLeftPart.zPosition = 1000
        alpha = 0
        anchorPoint = CGPointZero
        backgroundLeftPart.anchorPoint = CGPointZero
        backgroundLeftPart.position.x = -backgroundLeftPart.size.width
        addChild(backgroundLeftPart)
        
        addChild(buttonRestart)
        buttonRestart.addChild(createLabel("ЗАНОВО", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero))
        
        addChild(buttonContinue)
        buttonContinue.addChild(createLabel("ПРОДОЛЖИТЬ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero))
        
        addChild(buttonExit)
        buttonExit.addChild(createLabel("ВЫЙТИ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPointZero))
        
        show()
        userInteractionEnabled = true
        
        soundSwitcher.position = CGPoint(x: 206.5, y: 552)
        soundSwitcher.zPosition = 1001
        backgroundLeftPart.addChild(soundSwitcher)
        
        let soundLabel = createLabel("Звуки", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 205.5, y: 473))
        backgroundLeftPart.addChild(soundLabel)
        
        musicSwitcher.position = CGPoint(x: 404, y: 552)
        musicSwitcher.zPosition = 1001
        backgroundLeftPart.addChild(musicSwitcher)
        
        let musicLabel = createLabel("Музыка", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 404.5, y: 473))
        backgroundLeftPart.addChild(musicLabel)
    }
    
    func show() {
        let appear = SKAction.fadeInWithDuration(0.15)
        let moveLeftPart = SKAction.moveByX(backgroundLeftPart.size.width, y: 0, duration: 0.15)
        backgroundLeftPart.runAction(moveLeftPart)
        runAction(appear)
        
    }
    
    func hide() {
        let disappear = SKAction.fadeOutWithDuration(0.15)
        let moveLeftPart = SKAction.moveByX(-backgroundLeftPart.size.width, y: 0, duration: 0.15)
        backgroundLeftPart.runAction(moveLeftPart)
        runAction(SKAction.sequence([disappear, SKAction.removeFromParent()]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            switch node {
            case buttonContinue, buttonRestart, buttonExit:
                let button = node as! GameButton
                button.touched()
            case backgroundLeftPart:
                return
            default:
                hide()
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        for touch in touches! {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            switch node {
            case buttonContinue, buttonRestart, buttonExit:
                let button = node as! GameButton
                button.resetTexture()
            case backgroundLeftPart:
                return
            default:
                hide()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            switch node {
            case buttonRestart, buttonRestart.children[0] :
                buttonRestart.resetTexture()
                GameProgress.sharedInstance.newGame(scene!.view!)
            case backgroundLeftPart:
                return
            case buttonExit, buttonExit.children[0] :
                GameProgress.sharedInstance.goToMenu(scene!.view!)
            case soundSwitcher, musicSwitcher:
                return
            default:
                if let scene = self.scene as? LevelScene {
                    hide()
                    scene.background.paused = false
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}