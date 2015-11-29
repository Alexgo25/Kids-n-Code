//
//  EndLevelView.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 03.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class EndLevelView: SKSpriteNode {
    private let buttonRestart = GameButton(type: .Restart_EndLevelView)
    private let buttonNextLevel = GameButton(type: .NextLevel_EndLevelView)
    private let buttonExit = GameButton(type: .Exit_EndLevelView)
    
    init() {
        let texture = SKTexture(imageNamed: "EndLevelView_Background") //background.texture!
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        let levelData = GameProgress.sharedInstance.getCurrentLevelData()
        
        let result_1 = levelData["result_1"] as! Int
        let result_2 = levelData["result_2"] as! Int

        let actionsCount = ActionCell.cellsCount()
    
        GameProgress.sharedInstance.writeResultOfCurrentLevel(actionsCount)
        var batteryTexture = SKTexture()
        if actionsCount <= result_1 {
            batteryTexture = SKTexture(imageNamed: "battery_3")
            addChild(createLabel("Молодец! Ты нашел оптимальный алгоритм!", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1125.5)))
        } else if actionsCount <= result_2 {
            batteryTexture = SKTexture(imageNamed: "battery_2")
            addChild(createLabel("Отлично! Осталось изменить всего несколько", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1151)))
            addChild(createLabel("действий, чтобы алгоритм стал оптимальным...", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1093)))
        } else {
            batteryTexture = SKTexture(imageNamed: "battery_1")
            addChild(createLabel("Хорошо! Теперь давай попробуем составить", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1151)))
            addChild(createLabel("программу с меньшим количеством действий", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1093)))
        }
        
        let battery = SKSpriteNode(texture: batteryTexture)
        
        zPosition = 3000

        anchorPoint = CGPointZero
        
        addChild(buttonRestart)
        addChild(createLabel("Заново", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1018.5, y: 670)))
        
        addChild(buttonNextLevel)
        addChild(createLabel("Играть дальше", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1363, y: 670)))
        
        addChild(buttonExit)
        addChild(createLabel("Выйти в меню", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 672, y: 670)))
        
        battery.position = Constants.Battery_EndLevelViewPosition
        battery.zPosition = 1
        addChild(battery)
        
        userInteractionEnabled = true

        show()
    }
    
    func show() {
        alpha = 0
        let appear = SKAction.fadeInWithDuration(0.2)
        runAction(appear)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            switch node {
            case buttonRestart:
                GameProgress.sharedInstance.newGame(scene!.view!)
            case buttonNextLevel:
                GameProgress.sharedInstance.setNextLevel()
                GameProgress.sharedInstance.newGame(scene!.view!)
                
            case buttonExit:
                GameProgress.sharedInstance.goToMenu(scene!.view!)
            default:
                return
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
