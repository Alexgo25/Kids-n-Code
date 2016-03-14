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
        let levels = VirusedLevelsGameProgress.levelsInfo
        for (var i = 0 ; i < 4 ; i++) {
            for (var j = 0 ; j < 4; j++) {
                var folderState : FolderState!
                if (folders.count < 15) {
                    let level = levels[folders.count] //as! LevelConfiguration
                    let nextLevel = levels[folders.count + 1] //as! LevelConfiguration
                    if (level.isOpened) {
                        if (!nextLevel.isOpened) {
                            folderState = .Current
                        }
                        else {
                            folderState = .Opened
                        }
                    }
                    else {
                        folderState = .Closed
                    }
                }
                else {
                    let level = levels[folders.count] //as! LevelConfiguration
                    if (level.isOpened) {
                        if (level.currentResult == 0) {
                            folderState = .Current
                        }
                        else {
                            folderState = .Opened
                        }
                    }
                    else {
                        folderState = .Closed
                    }
                }
                
                let folder = Folder(folderState: folderState, number: folders.count + 1)
                folder.position = CGPoint(x: menuColumnPositionX[j], y: menuRowPositionY[i])
                addChild(folder)
                folders.append(folder)
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

