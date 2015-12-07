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
    private let backgroundLeftPart = SKSpriteNode(imageNamed: "pauseBackgroundLeftPart")
    private let backgroundRightPart = SKSpriteNode(imageNamed: "pauseBackgroundRightPart")
    
    private let buttonRestart = GameButton(type: .Restart_PauseView)
    private let buttonContinue = GameButton(type: .Continue_PauseView)
    private let buttonExit = GameButton(type: .Exit_PauseView)
    
    private let soundSwitcher: SoundSwitcher
    private let musicSwitcher: MusicSwitcher
    
    init() {
        musicSwitcher = MusicSwitcher()
        soundSwitcher = SoundSwitcher()
        super.init(texture: nil, color: UIColor(), size: CGSize())

        anchorPoint = CGPointZero
        userInteractionEnabled = true
        zPosition = 3000
        
        createBackground()
        show()
    }
    
    func createBackground() {
        backgroundLeftPart.zPosition = 1000
        backgroundLeftPart.anchorPoint = CGPointZero
        backgroundLeftPart.position.x = -backgroundLeftPart.size.width
        addChild(backgroundLeftPart)
        
        backgroundLeftPart.addChild(soundSwitcher)
        backgroundLeftPart.addChild(musicSwitcher)
        
        let soundLabel = createLabel("Звуки", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 205.5, y: 473))
        backgroundLeftPart.addChild(soundLabel)
        
        let musicLabel = createLabel("Музыка", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 404.5, y: 473))
        backgroundLeftPart.addChild(musicLabel)
        
        addChild(buttonRestart)
        addChild(buttonContinue)
        addChild(buttonExit)
        
        backgroundRightPart.zPosition = 999
        backgroundRightPart.anchorPoint = CGPointZero
        addChild(backgroundRightPart)
    }
    
    func show() {
        alpha = 0
        let appear = SKAction.fadeInWithDuration(0.15)
        let moveLeftPart = SKAction.moveByX(backgroundLeftPart.size.width, y: 0, duration: 0.15)
        backgroundLeftPart.runAction(moveLeftPart)
        runAction(appear)
    }
    
    func hide() {
        TouchesAnalytics.sharedInstance.appendTouch("returnFromPause")
        let disappear = SKAction.fadeOutWithDuration(0.15)
        let moveLeftPart = SKAction.moveByX(-backgroundLeftPart.size.width, y: 0, duration: 0.15)
        backgroundLeftPart.runAction(moveLeftPart)
        
        runAction(SKAction.sequence([disappear, SKAction.removeFromParent()]))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            TouchesAnalytics.sharedInstance.appendTouch(buttonRestart.name!)
            switch node {
            case buttonRestart:
                GameProgress.sharedInstance.newGame(scene!.view!)
            case buttonExit:
                NSNotificationCenter.defaultCenter().postNotificationName(kPauseQuitNotificationKey, object: NotificationZombie.sharedInstance)
                GameProgress.sharedInstance.goToMenu(scene!.view!)
            case buttonContinue, backgroundRightPart:
                hide()
                weak var scene = self.scene as? LevelScene
                scene!.background.paused = false
            default:
                return
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}