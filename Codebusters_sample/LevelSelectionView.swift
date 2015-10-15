//
//  LevelSelectionView.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 10.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class LevelSelectionView: SKSpriteNode {
    
    let levelPackIndex: Int
    let levelsCount: Int
    
    init(levelPackIndex: Int) {
        
        let texture = SKTexture(imageNamed: "LevelSelectionView_Background")
        self.levelPackIndex = levelPackIndex
        let levels = GameProgress.sharedInstance.getLevelPackData(levelPackIndex)
        levelsCount = levels.count
        
        super.init(texture: texture, color: SKColor(), size: texture.size())
        
        Battery.count = 0
        
        for levelResult in levels {
            if let batteryType = Type(rawValue: levelResult) {
                let battery = Battery(type: batteryType)
                battery.position = getNextPosition()
                addChild(battery)
            }
        }
        
        anchorPoint = CGPointZero
        zPosition = 3000
        userInteractionEnabled = true
        
        show()
    }
    
    func show() {
        alpha = 0
        let appear = SKAction.fadeInWithDuration(0.2)
        runAction(appear)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            if let battery = nodeAtPoint(touchLocation) as? Battery {
                if battery.type.rawValue >= 0 {
                    GameProgress.sharedInstance.setLevel(levelPackIndex, level: Int(battery.name!)!)
                    GameProgress.sharedInstance.newGame(scene!.view!)
                }
            } else {
                runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.2), SKAction.removeFromParent()]))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getNextPosition() -> CGPoint {
        if levelsCount < 5 {
            let dx: CGFloat = 422
            if Battery.count < 3 {
                return CGPoint(x: Battery.firstPositionSecondRow.x + dx * (Battery.count - 1) - 50, y: Battery.firstPositionFirstRow.y)
            } else {
                return CGPoint(x: Battery.firstPositionSecondRow.x + dx * (Battery.count - 3) - 50, y: Battery.firstPositionSecondRow.y)
            }
        } else {
            let dx: CGFloat = 322
            if Battery.count < 4 {
                return CGPoint(x: Battery.firstPositionFirstRow.x + dx * (Battery.count - 1), y: Battery.firstPositionFirstRow.y)
            } else {
                return CGPoint(x: Battery.firstPositionSecondRow.x + dx * (Battery.count - 4), y: Battery.firstPositionSecondRow.y)
            }
        }
    }
}

internal enum Type: Int {
    case Excellent = 3,
    Good = 2,
    Bad = 1,
    Opened = 0,
    Closed = -1
}

internal class Battery: SKSpriteNode {

    static let firstPositionFirstRow = CGPoint(x: 711.5, y: 842)
    static let firstPositionSecondRow = CGPoint(x: 871.5, y: 562)
    static var count: CGFloat = 0
    
    private let type: Type
    
    init(type: Type) {
        self.type = type
        super.init(texture: nil, color: SKColor.clearColor(), size: CGSize())

        name = String(Int(Battery.count))
        Battery.count++
        zPosition = 1003
        
        var battery = SKSpriteNode(imageNamed: "battery_\(type.rawValue)")
        
        if type.rawValue < 0 {
            battery = SKSpriteNode(imageNamed: "battery_0")
        }
        
        battery.zPosition = -1002
        
        if type.rawValue > 0 {
            battery.setScale(1/2.78)
        }
        
        addChild(battery)
        
        switch type {
        case .Excellent, .Good, .Bad:
            let number = SKSpriteNode(imageNamed: "nonActive")
            number.zPosition = -1002
            number.addChild(createLabel(String(Int(Battery.count)), fontColor: SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), fontSize: 36, position: CGPointZero))
            number.position.y = 114
            addChild(number)
        case .Opened:
            let number = SKSpriteNode(imageNamed: "active")
            number.zPosition = -1002
            number.addChild(createLabel(String(Int(Battery.count)), fontColor: SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), fontSize: 36, position: CGPointZero))
            number.position.y = 114
            addChild(number)
        
        case .Closed:
            let number = SKSpriteNode(imageNamed: "nonActive")
            number.alpha = 0.5
            number.zPosition = -1002
            number.addChild(createLabel(String(Int(Battery.count)), fontColor: SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), fontSize: 36, position: CGPointZero))
            number.position.y = 114
            addChild(number)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
