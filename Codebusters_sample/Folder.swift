//
//  Folder.swift
//  Kids'n'Code
//
//  Created by Alexander on 14/03/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

enum FolderState {
    case Closed,
    Current,
    Opened,
    Bad_Result,
    Avg_Result,
    Good_Result
}

class Folder : SKSpriteNode {
    
    var folderState : FolderState
    
    init(folderState : FolderState , number : Int) {
        let texture = SKTexture(imageNamed: "folder")
        self.folderState = folderState
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = 1000
        var circle : SKTexture!
        var color : UIColor!
        switch folderState {
        case .Closed:
            circle = SKTexture(imageNamed: "closedCircle")
            color = UIColor.brownColor()
            let circleNode = SKSpriteNode(texture: circle)
            circleNode.zPosition = 1001
            circleNode.position = CGPoint(x: 0, y: -10)
            addChild(circleNode)
            let label = createLabel(String(number), fontColor: color, fontSize: 23, position: CGPoint(x: 0, y: 0))
            circleNode.addChild(label)

        case .Opened :
            circle = SKTexture(imageNamed: "completedCircle")
            color = UIColor.brownColor()
            let circleNode = SKSpriteNode(texture: circle)
            circleNode.zPosition = 1001
            circleNode.position = CGPoint(x: 0, y: -10)
            addChild(circleNode)
            let label = createLabel(String(number), fontColor: color, fontSize: 23, position: CGPoint(x: 0, y: 0))
            circleNode.addChild(label)
        
        case .Good_Result:
            circle = SKTexture(imageNamed: "smallCircle")
            color = UIColor.blackColor()
            let circleNode = SKSpriteNode(texture: circle)
            circleNode.zPosition = 1001
            circleNode.position = CGPoint(x: -60, y: 25)
            addChild(circleNode)
            let label = createLabel(String(number), fontColor: color, fontSize: 14, position: CGPoint(x: 0, y: 0))
            circleNode.addChild(label)
            let battery = SKSpriteNode(texture: SKTexture(imageNamed: "battery_good"))
            battery.position = CGPoint(x: 0, y: -15)
            battery.zPosition = 1001
            addChild(battery)
            
        case .Avg_Result:
            circle = SKTexture(imageNamed: "smallCircle")
            color = UIColor.blackColor()
            let circleNode = SKSpriteNode(texture: circle)
            circleNode.zPosition = 1001
            circleNode.position = CGPoint(x: -60, y: 25)
            addChild(circleNode)
            let label = createLabel(String(number), fontColor: color, fontSize: 14, position: CGPoint(x: 0, y: 0))
            circleNode.addChild(label)
            let battery = SKSpriteNode(texture: SKTexture(imageNamed: "battery_avg"))
            battery.position = CGPoint(x: 0, y: -15)
            battery.zPosition = 1001
            addChild(battery)
        
        case .Bad_Result:
            circle = SKTexture(imageNamed: "smallCircle")
            color = UIColor.blackColor()
            let circleNode = SKSpriteNode(texture: circle)
            circleNode.zPosition = 1001
            circleNode.position = CGPoint(x: -60, y: 25)
            addChild(circleNode)
            let label = createLabel(String(number), fontColor: color, fontSize: 14, position: CGPoint(x: 0, y: 0))
            circleNode.addChild(label)
            let battery = SKSpriteNode(texture: SKTexture(imageNamed: "battery_bad"))
            battery.position = CGPoint(x: 0, y: -15)
            battery.zPosition = 1001
            addChild(battery)



        default:
            circle = SKTexture(imageNamed: "openedCircle")
            color = UIColor.whiteColor()
            let circleNode = SKSpriteNode(texture: circle)
            circleNode.zPosition = 1001
            circleNode.position = CGPoint(x: 0, y: -10)
            addChild(circleNode)
            let label = createLabel(String(number), fontColor: color, fontSize: 23, position: CGPoint(x: 0, y: 0))
            circleNode.addChild(label)

        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
