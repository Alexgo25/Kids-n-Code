//
//  Switcher.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 18.09.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//
import Foundation
import SpriteKit
import AVFoundation

class Switcher: SKSpriteNode {
    private let switcher: SKSpriteNode
    private var label: SKLabelNode
    private var switchedOn: Bool = true
    
    init() {
        let atlas = SKTextureAtlas(named: "PauseView")
        let texture = atlas.textureNamed("SwitcherBackground_On_PauseView")
        
        let switcherTexture = SKTexture(imageNamed: "Switcher_PauseView.png")
        switcher = SKSpriteNode(texture: switcherTexture)
        switcher.position = CGPoint(x: -52, y: 0)
        
        label = createLabel("ВКЛ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPoint(x: 22.5, y: 0))
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        addChild(switcher)
        addChild(label)
        
        userInteractionEnabled = false
    }

    func isSwitchedOn() -> Bool {
        return switchedOn
    }
    
    private func switchOn() {
        switchedOn = true
        
        let atlas = SKTextureAtlas(named: "PauseView")
        let texture = atlas.textureNamed("SwitcherBackground_On_PauseView")
        let changeTexture = SKAction.setTexture(texture, resize: true)
        let moveSwitcher = SKAction.moveByX(-103, y: 0, duration: 0.1)
        
        let newLabelPosition = CGPoint(x: 22.5, y: 0)
        
        label.text = ""
        switcher.runAction(moveSwitcher, completion: {
            self.runAction(changeTexture)
            self.label.position = newLabelPosition
            self.label.text = "ВКЛ"
        })
    }
    
    func switchOff() {
        switchedOn = false
        
        let atlas = SKTextureAtlas(named: "PauseView")
        let texture = atlas.textureNamed("SwitcherBackground_Off_PauseView")
        let changeTexture = SKAction.setTexture(texture, resize: true)
        let moveSwitcher = SKAction.moveByX(103, y: 0, duration: 0.1)
        
        let newLabelPosition = CGPoint(x: -29.5, y: 0)
        
        label.text = ""
        
        switcher.runAction(moveSwitcher, completion: {
            self.runAction(changeTexture)
            self.label.position = newLabelPosition
            self.label.text = "ВЫКЛ"
        })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if switchedOn {
            switchOff()
        } else {
            switchOn()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MusicSwitcher: SKSpriteNode {
    private let switcher: Switcher
    
    init() {
        switcher = Switcher()
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSize())
        addChild(switcher)
        
        userInteractionEnabled = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if switcher.isSwitchedOn() {
            AudioPlayer.sharedInstance.pauseBackgroundMusic()
            GameProgress.sharedInstance.changeSetting("music", value: "Off")
        } else {
            AudioPlayer.sharedInstance.resumeBackgroundMusic()
            GameProgress.sharedInstance.changeSetting("music", value: "On")
        }
        
        switcher.touchesEnded(touches, withEvent: event)
    }
    
    func switchOff() {
        switcher.switchOff()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SoundSwitcher: SKSpriteNode {
    private let switcher: Switcher
    
    init() {
        switcher = Switcher()
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSize())
        addChild(switcher)
        
        userInteractionEnabled = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if switcher.isSwitchedOn() {
            AudioPlayer.sharedInstance.soundsAreOn = false
            GameProgress.sharedInstance.changeSetting("sounds", value: "Off")
        } else {
            AudioPlayer.sharedInstance.soundsAreOn = true
            GameProgress.sharedInstance.changeSetting("sounds", value: "On")
        }
        
        switcher.touchesEnded(touches, withEvent: event)
    }
    
    func switchOff() {
        switcher.switchOff()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}