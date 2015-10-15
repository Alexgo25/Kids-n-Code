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
    private let label_On = createLabel("ВКЛ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPoint(x: 22.5, y: 0))
    private let label_Off = createLabel("ВЫКЛ", fontColor: UIColor.whiteColor(), fontSize: 29, position: CGPoint(x: -29.5, y: 0))
    
    private let atlas = SKTextureAtlas(named: "PauseView")
    private let switcher: SKSpriteNode
    
    private var parameter: UnsafeMutablePointer<Bool> = nil
    
    
    init(parameter: UnsafeMutablePointer<Bool>, name: String) {
        self.parameter = parameter
        
        switcher = SKSpriteNode(texture: atlas.textureNamed("Switcher_PauseView"))
        
        let texture = atlas.textureNamed("SwitcherBackground_On_PauseView")
        super.init(texture: texture, color: UIColor(), size: texture.size())
        self.name = name
        switcher.position = CGPoint(x: -52, y: 0)
        
        addChild(switcher)
        addChild(label_On)
        
        userInteractionEnabled = true
    }
    
    func isSwitchedOn() -> Bool {
        return parameter.memory
    }
    
    func switchOn() {
        
        let changeBackground = SKAction.runBlock() {
            self.texture = self.atlas.textureNamed("SwitcherBackground_On_PauseView")
        }
        
        let moveSwitcher = SKAction.moveByX(-103, y: 0, duration: 0.1)
        
        let removeLabel = SKAction.runBlock() {
            self.label_Off.removeFromParent()
        }
        
        let addLabel = SKAction.runBlock() {
            self.addChild(self.label_On)
        }
        
        let sequence = SKAction.sequence([removeLabel, moveSwitcher, changeBackground, addLabel])
        switcher.runAction(sequence)
        
        parameter.memory = true
        
        GameProgress.sharedInstance.changeSetting(name!, value: "On")
    }
    
    func switchOff() {
        let changeBackground = SKAction.runBlock() {
            self.texture = self.atlas.textureNamed("SwitcherBackground_Off_PauseView")
        }
        
        let moveSwitcher = SKAction.moveByX(103, y: 0, duration: 0.1)
        
        let removeLabel = SKAction.runBlock() {
            self.label_On.removeFromParent()
        }
        
        let addLabel = SKAction.runBlock() {
            self.addChild(self.label_Off)
        }
        
        let sequence = SKAction.sequence([removeLabel, moveSwitcher, changeBackground, addLabel])
        switcher.runAction(sequence)
        
        parameter.memory = false
        
        GameProgress.sharedInstance.changeSetting(name!, value: "Off")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isSwitchedOn() {
            switchOff()
        } else {
            switchOn()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MusicSwitcher: SKNode {
    private let switcher: Switcher
    
    init(switcher: Switcher) {
        self.switcher = switcher
        super.init()
        switcher.userInteractionEnabled = false
        addChild(switcher)
        
        userInteractionEnabled = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if switcher.isSwitchedOn() {
            AudioPlayer.sharedInstance.pauseBackgroundMusic()
        } else {
            AudioPlayer.sharedInstance.resumeBackgroundMusic()
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