//
//  LevelSelectionView.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 10.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

class LevelSelectionView: SKSpriteNode {
    let levelsCount: Int
    
    init(levelPackIndex: Int, levels: [[String: AnyObject]]) {
        levelsCount = levels.count
        
        let texture = SKTexture(imageNamed: "LevelSelectionView_Background")
        super.init(texture: texture, color: SKColor(), size: texture.size())
        
        for var levelNumber = 0; levelNumber < levelsCount; levelNumber++ {
            let battery = Battery(type: getBatteryType(levels[levelNumber]), levelNumber: levelNumber, levelPackNumber: levelPackIndex)
            battery.position = getNextPosition(levelNumber)
            addChild(battery)
        }
    
        anchorPoint = CGPointZero
        userInteractionEnabled = true
        zPosition = 3000
    }
    
    func getBatteryType(level: [String: AnyObject]) -> Type {
        if !(level["isOpened"] as! Bool) {
            return .Closed
        }
        
        let result = level["result"] as! Int
        let goodResult = level["result_1"] as! Int
        let badResult = level["result_2"] as! Int
        
        if result == 0 {
            return .Opened
        }
        
        return result <= goodResult ? .Excellent : (result <= badResult ? .Good : .Bad)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.2), SKAction.removeFromParent()]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getNextPosition(batteryNumber: Int) -> CGPoint {
        if levelsCount < 5 {
            let dx: CGFloat = 422
            if batteryNumber < 2 {
                return CGPoint(x: Battery.firstPositionSecondRow.x + dx * CGFloat(batteryNumber) - 50, y: Battery.firstPositionFirstRow.y)
            } else {
                return CGPoint(x: Battery.firstPositionSecondRow.x + dx * CGFloat(batteryNumber - 2) - 50, y: Battery.firstPositionSecondRow.y)
            }
        } else {
            let dx: CGFloat = 322
            if batteryNumber < 3 {
                return CGPoint(x: Battery.firstPositionFirstRow.x + dx * CGFloat(batteryNumber), y: Battery.firstPositionFirstRow.y)
            } else {
                return CGPoint(x: Battery.firstPositionSecondRow.x + dx * CGFloat(batteryNumber - 3), y: Battery.firstPositionSecondRow.y)
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
    
    let type: Type
    let levelNumber: Int
    let levelPackNumber: Int
    
    init(type: Type, levelNumber: Int, levelPackNumber: Int) {
        self.type = type
        self.levelNumber = levelNumber
        self.levelPackNumber = levelPackNumber
        
        let texture = type.rawValue < 0 ? SKTexture(imageNamed: "battery_0") : SKTexture(imageNamed: "battery_\(type.rawValue)")
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        zPosition = 1003
        
        var battery : SKSpriteNode
        
        if type.rawValue < 0 {
            battery = SKSpriteNode(imageNamed: "battery_0")
        }
        else {
            battery = SKSpriteNode(imageNamed: "battery_\(type.rawValue)")
        }
        
        battery.zPosition = -1002
        
        if type.rawValue > 0 {
            setScale(1/2.78)
        }
        
        let number = type == .Opened ? SKSpriteNode(imageNamed: "Active") : SKSpriteNode(imageNamed: "NonActive")
        number.zPosition = -1002
        number.addChild(createLabel(String(levelNumber + 1), fontColor: SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), fontSize: 36, position: CGPointZero))
        number.position.y = 114
        if type == .Excellent || type == .Good || type == .Bad {
            number.position.y = 114 * 2.78
            number.setScale(2.78)
        }
        addChild(number)
        
        userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if type != .Closed {
            sceneManager.presentScene(.Level(levelPackNumber, levelNumber))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}