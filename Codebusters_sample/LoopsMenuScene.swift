//
//  LoopsMenuScene.swift
//  Kids'n'Code
//
//  Created by Alexander on 26/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.

import Foundation
import UIKit
import Google
import SpriteKit

let menuRowPositionY = [1028.0, 833.0, 650.0, 462.0]
let menuColumnPositionX = [649.0 , 895.0 , 1150.0 , 1396.0]

class LoopsMenuScene: SceneTemplate {
    
    let background = SKSpriteNode(imageNamed: "loopsMenuBackground")
    let buttonPause = GameButton(type: .Pause)
    var folders : [SKSpriteNode] = []
    
    
    override init() {
        super.init()
        addChild(background)
        background.anchorPoint = CGPointZero
        background.zPosition = -1
        addChild(buttonPause)
        addFolders()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
    }
    
    func addFolders() {
        for (var i = 0 ; i < 4 ; i++) {
            for (var j = 0 ; j < 4; j++) {
                let folder = SKSpriteNode(imageNamed: "folder")
                folder.position = CGPoint(x: menuColumnPositionX[i], y: menuRowPositionY[j])
                folder.zPosition = 1000
                let circle = SKSpriteNode(imageNamed: "ellipse")
                circle.zPosition = 1001
                circle.position = CGPoint(x: 0, y: 0)
                folder.addChild(circle)
                addChild(folder)
                folders.append(folder)
                let label = createLabel(String(folders.count), fontColor: UIColor.brownColor(), fontSize: 23, position: CGPoint(x: 0, y: 0))
                circle.addChild(label)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            
            if let touchedNode = nodeAtPoint(touchLocation) as? SKSpriteNode {
                if (folders.contains(touchedNode)) {
                    let index = folders.indexOf(touchedNode)!
                    sceneManager.presentScene(.VirusedLevel(index))
                }
            }
        }
    }

    
}

