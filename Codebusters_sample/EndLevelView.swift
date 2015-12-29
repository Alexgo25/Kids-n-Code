//
//  EndLevelView.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 03.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

let kGoodAlgorithmString = NSLocalizedString("GOOD_ALGORITHM", comment: "Good algorithm")
let kAvgAlgorithm1String = NSLocalizedString("AVG_ALGORITHM1", comment: "Avg algorith 1st part")
let kAvgAlgorithm2String = NSLocalizedString("AVG_ALGORITHM2", comment: "Avg algorithm 2nd part")
let kBadAlgorithm1String = NSLocalizedString("BAD_ALGORITHM1", comment: "Bad algorithm 1st part")
let kBadAlgorithm2String = NSLocalizedString("BAD_ALGORITHM2", comment: "Bad algorithm 2nd part")

class EndLevelView: SKSpriteNode {
    let Battery_EndLevelViewPosition = CGPoint(x: 1032.5, y: 889)
    
    private let buttonRestart = GameButton(type: .Restart_EndLevelView)
    private let buttonNextLevel = GameButton(type: .NextLevel_EndLevelView)
    private let buttonExit = GameButton(type: .Exit_EndLevelView)
    
    init(levelInfo: LevelConfiguration, result: Int) {
        let texture = SKTexture(imageNamed: "EndLevelView_Background") //background.texture!
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
        let goodResult = levelInfo.goodResult
        let badResult = levelInfo.badResult
        
        var batteryTexture = SKTexture()
        if result <= goodResult {
            batteryTexture = SKTexture(imageNamed: "battery_3")
            addChild(createLabel(kGoodAlgorithmString, fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1125.5)))
        } else if result <= badResult {
            batteryTexture = SKTexture(imageNamed: "battery_2")
            addChild(createLabel(kAvgAlgorithm1String, fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1151)))
            addChild(createLabel(kAvgAlgorithm2String, fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1093)))
        } else {
            batteryTexture = SKTexture(imageNamed: "battery_1")
            addChild(createLabel(kBadAlgorithm1String, fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1151)))
            addChild(createLabel(kBadAlgorithm2String, fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1039.5, y: 1093)))
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
