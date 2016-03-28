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
    let buttonPause = GameButton(type: .Quit)
    lazy var folders : [Folder] = []
    
    
    
      init(data : [[String : AnyObject]]) {
        super.init()
        addChild(background)
        background.anchorPoint = CGPointZero
        background.zPosition = -1
        addChild(buttonPause)
        addFolders(data)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
    }
    
    func addFolders(levels : [[String: AnyObject]]) {
        for i in 0  ..< 4  {
            for j in 0  ..< 4 {
                var folderState : FolderState!
                if (folders.count < 15) {
                    let level = levels[folders.count]
                    let nextLevel = levels[folders.count + 1]
                    if ((level[kIsOpenedKey] as! Bool) == true) {
                        if ((nextLevel[kIsOpenedKey] as! Bool) == false) {
                            folderState = .Current
                        }
                        else {
                            if let result = level["result"] as? Int {
                                let result_1 = level["result_1"] as? Int
                                if (result <= result_1) {
                                    folderState = .Good_Result
                                }
                                else {
                                    let result_2 = level["result_2"] as? Int
                                    if (result <= result_2) {
                                        folderState = .Avg_Result
                                    }
                                    else {
                                        folderState = .Bad_Result
                                    }
                                }
                            }
                            else {
                                folderState = .Opened

                            }
                            
                        }
                    }
                    else {
                        folderState = .Closed
                    }
                }
                else {
                    let level = levels[folders.count]
                    if ((level[kIsOpenedKey] as! Bool) == true) {
                        if ((level["result"] as! Int)  == 0) {
                            folderState = .Current
                        }
                        else {
                            if let result = level["result"] as? Int {
                                let result_1 = level["result_1"] as? Int
                                if (result <= result_1) {
                                    folderState = .Good_Result
                                }
                                else {
                                    let result_2 = level["result_2"] as? Int
                                    if (result <= result_2) {
                                        folderState = .Avg_Result
                                    }
                                    else {
                                        folderState = .Bad_Result
                                    }
                                }
                            }
                            else {
                                folderState = .Opened
                                
                            }

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
                if let folder = touchedNode as? Folder {
                    let index = folders.indexOf(folder)!
                    if (folders[index].folderState != .Closed) {
                        sceneManager.presentScene(.VirusedLevel(index))
                    }
                    
                }
                else {
                    if let parent = touchedNode.parent as? Folder {
                        let index = folders.indexOf(parent)!
                        if (folders[index].folderState != .Closed) {
                            sceneManager.presentScene(.VirusedLevel(index))
                        }

                    }
                }
            }
        }
    }
    
    override func buttonPressed(button: ButtonNode) {
        if let btn = button as? GameButton {
            if (btn.gameButtonType == .Quit) {
                sceneManager.presentScene(.Menu)
            }
        }
    }

    
}

