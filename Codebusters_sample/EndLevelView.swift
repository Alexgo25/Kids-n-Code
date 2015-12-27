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
    let Battery_EndLevelViewPosition = CGPoint(x: 1032.5, y: 889)
    
    private let buttonRestart = GameButton(type: .Restart_EndLevelView)
    private let buttonNextLevel = GameButton(type: .NextLevel_EndLevelView)
    private let buttonExit = GameButton(type: .Exit_EndLevelView)

    
    init() {

        let texture = SKTexture(imageNamed: "EndLevelView_Background") //background.texture!
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        let result = levelInfo.currentResult
        let goodResult = levelInfo.goodResult
        let badResult = levelInfo.badResult

        var batteryTexture = SKTexture()
        if result <= goodResult {
            batteryTexture = SKTexture(imageNamed: "battery_3")
            addChild(createLabel("Молодец! Ты нашел оптимальный алгоритм!", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1125.5)))
        } else if result <= badResult {
            batteryTexture = SKTexture(imageNamed: "battery_2")
            addChild(createLabel("Отлично! Осталось изменить всего несколько", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1151)))
            addChild(createLabel("действий, чтобы алгоритм стал оптимальным...", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1093)))
        } else {
            batteryTexture = SKTexture(imageNamed: "battery_1")
            addChild(createLabel("Хорошо! Теперь давай попробуем составить", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1151)))
            addChild(createLabel("программу с меньшим количеством действий", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1093)))
        }
        
        let battery = SKSpriteNode(texture: batteryTexture)
        
        zPosition = 4000
        anchorPoint = CGPointZero
        addChild(buttonRestart)
        addChild(createLabel("Заново", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1018.5, y: 670)))
        
        addChild(buttonNextLevel)
        addChild(createLabel("Играть дальше", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1363, y: 670)))
        
        addChild(buttonExit)
        addChild(createLabel("Выйти в меню", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 672, y: 670)))
        
        battery.position = Battery_EndLevelViewPosition
        battery.zPosition = 1
        addChild(battery)
        
        userInteractionEnabled = true

        show()
        NSNotificationCenter.defaultCenter().postNotificationName(kShowAdsNotificationKey, object: NotificationZombie.sharedInstance)
    }
    
    
    
    func show() {
        alpha = 0
        let appear = SKAction.fadeInWithDuration(0.2)
        runAction(appear)
    }
    
    func buttonPressed(button: GameButton) {
        switch button.gameButtonType {
        case .Restart_EndLevelView:
            GameProgress.sharedInstance.newGame(scene!.view!)
        case .NextLevel_EndLevelView:
            GameProgress.sharedInstance.setNextLevel()
            GameProgress.sharedInstance.newGame(scene!.view!)
        case .Exit_EndLevelView:
            GameProgress.sharedInstance.goToMenu(scene!.view!)
        default:
            return
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
