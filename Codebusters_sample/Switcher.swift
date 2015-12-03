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
        
        name = "MusicSwitcher"
        userInteractionEnabled = true
        
        if !AudioPlayer.sharedInstance.musicIsOn {
            switcher.switchOff()
        }
        
        position = CGPoint(x: 404, y: 552)
        zPosition = 1001
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if switcher.isSwitchedOn() {
            AudioPlayer.sharedInstance.pauseBackgroundMusic()
            defaults.setBool(false, forKey: "music")
        } else {
            AudioPlayer.sharedInstance.resumeBackgroundMusic()
            defaults.setBool(true, forKey: "music")
        }
        
        switcher.touchesEnded(touches, withEvent: event)
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
        
        name = "SoundSwitcher"
        userInteractionEnabled = true
        
        if !AudioPlayer.sharedInstance.soundsAreOn {
            switcher.switchOff()
        }
        
        position = CGPoint(x: 206.5, y: 552)
        zPosition = 1001
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if switcher.isSwitchedOn() {
            AudioPlayer.sharedInstance.soundsAreOn = false
            defaults.setBool(false, forKey: "sounds")
        } else {
            AudioPlayer.sharedInstance.soundsAreOn = true
            defaults.setBool(true, forKey: "sounds")
        }
        
        switcher.touchesEnded(touches, withEvent: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}