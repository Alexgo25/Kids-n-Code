//
//  VirusedLevelScene.swift
//  Kids'n'Code
//
//  Created by Alexander on 15/03/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

class VirusedLevelScene : LevelScene {

    var button_ReadyLoop : GameButton!
    var button_CancelLoop : GameButton!
    var loopControl = LoopControlFullRect()
    
    override func didMoveToView(view: SKView) {
        let size = sceneManager.size
        playAreaSize = CGSize(width: size.width - levelBackground2.size.width, height: size.height)
        ActionCell.gameIsRunning = false
        userInteractionEnabled = true
        anchorPoint = CGPointZero
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        ActionCell.cellsLayer.removeFromParent()
        addChild(ActionCell.cellsLayer)
        ActionCell.resetCells()
        
        //Analytics->start timer
        TimerDelegate.sharedTimerDelegate.startTimer()
        
        createBackground()
        createTrackLayer()
        
        addGestures()
        
        showDetailAndRobot()
        
        if let tutorial = levelInfo.tutorial {
            overlay = Tutorial(tutorialNumber: tutorial)
            sceneManager.virusedGameProgressManager.removeTutorial()
        }
    }

    override init(levelInfo: LevelConfiguration) {
        super.init(levelInfo: levelInfo)
        LevelScene.loopsEnabled = levelInfo.loopsEnabled
        levelBackground1 = SKSpriteNode(imageNamed: "virusedBackground1")
        levelBackground2 = SKSpriteNode(imageNamed: "virusedBackground2")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VirusedLevelScene.addNewControls), name: kActionCellSelectedKey, object: NotificationZombie.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VirusedLevelScene.removeNewControls), name: kActionCellDeselectAllKey, object: NotificationZombie.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(VirusedLevelScene.finishWithSuccess) , name:kRobotTookDetailNotificationKey, object: robot)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VirusedLevelScene.finishWithMistake), name: kPauseQuitNotificationKey, object: NotificationZombie.sharedInstance)

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createGameButtons() {
        button_Pause = GameButton(type: .Pause_Virused)
        button_Restart = GameButton(type: .Restart)
        button_Tips = GameButton(type: .Tips_Virused)
        button_Start = GameButton(type: .Start)
        button_Debug = GameButton(type: .Debug_Virused)
        button_Clear = GameButton(type: .Clear)
        button_ReadyLoop = GameButton(type: .ReadyLoop)
        button_CancelLoop = GameButton(type: .CancelLoop)
        createLabel(kNumberOfRepeatsLabel, fontColor: UIColor.blackColor(), fontSize: 28.56, position: CGPoint(x: 1800, y: 412))
    }
    
    func addNewControls() {
        //remove old
        print("addNewControls")
        let fadeOut = SKAction.group([SKAction.moveByX(-400, y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
        button_Clear.runAction(fadeOut)
        button_Start.runAction(fadeOut)
        button_Restart.runAction(fadeOut)
        button_Debug.runAction(fadeOut)
        let fadeIn = SKAction.group([SKAction.moveByX(-400, y: 0, duration: 0.2), SKAction.fadeInWithDuration(0.2)])
        button_CancelLoop.runAction(fadeIn)
        button_ReadyLoop.runAction(fadeIn)
        loopControl.appearInScene()
    }
    
    func removeNewControls() {
        print("removeNewControls")
        let fadeIn = SKAction.group([SKAction.moveByX(400, y: 0, duration: 0.2) , SKAction.fadeInWithDuration(0.2)])
        button_Clear.runAction(fadeIn)
        button_Start.runAction(fadeIn)
        button_Restart.runAction(fadeIn)
        button_Debug.runAction(fadeIn)
        let fadeOut = SKAction.group([SKAction.moveByX(400, y: 0, duration: 0.2) , SKAction.fadeOutWithDuration(0.2)])
        button_ReadyLoop.runAction(fadeOut)
        button_CancelLoop.runAction(fadeOut)
        loopControl.disappear()
    }
    
    override func createBackground() {
        super.createBackground()
        addChild(button_CancelLoop)
        addChild(button_ReadyLoop)
        addChild(loopControl)
    }
    
    func resetViruses() {
        
        if (track.viruses != []) {
            for virus in track.viruses {
                virus.removeFromParent()
            }
            track.viruses.removeAll(keepCapacity: false)
        }
        if (levelInfo.virusesPattern != []) {
            track.virused = true
            for virus in levelInfo.virusesPattern {
                if let dict = virus as? NSDictionary {
                    let floor = dict["virusFloorPosition"] as! Int
                    let flp = FloorPosition(rawValue: floor)
                    let pos = dict["virusPosition"] as! Int
                    let virus = LevelVirus(track: track, trackPosition: pos, floorPosition: flp!)
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.trackLayer.addChild(virus)
                    })
                }
                
            }
        }
    }
    
    override func createBlocks() {
        super.createBlocks()
        resetViruses()
    }

    
    override func buttonPressed(button: ButtonNode) {
        if let gameButton = button as? GameButton {
            switch gameButton.gameButtonType {
            case .Start:
                checkRobotPosition()
                robot.performActions()
                ActionCell.gameIsRunning = true
            case .Pause_Virused:
                pauseGame()
            case .Tips_Virused:
                if !robot.isRunningActions() {
                    overlay = Tutorial(tutorialNumber: 6)
                }
            case .Clear:
                ActionCell.gameIsRunning = false
                enumerateChildNodesWithName("clear") {
                    node, stop in
                    node.removeFromParent()
                }
                ActionCell.resetCellTextures()
                track.deleteBlocks()
                detail.removeFromParent()
                robot.removeFromParent()
                trackLayer.removeAllChildren()
                trackLayer.removeFromParent()
                track = RobotTrack(levelInfo: levelInfo)
                detail = Detail(track: track, levelInfo: levelInfo)
                robot = Robot(track: track, detail: detail)
                createTrackLayer()
                
            case .Debug_Virused:
                ActionCell.gameIsRunning = true
                robot.debug()
            case .Continue_PauseView, .Ok:
                overlay = nil
            case .Exit_PauseView, .Exit_EndLevelView:
                NSNotificationCenter.defaultCenter().postNotificationName(kPauseQuitNotificationKey, object: NotificationZombie.sharedInstance)
                sceneManager.presentScene(.Menu)
            case .Restart_PauseView, .Restart_EndLevelView, .Restart:
                    ActionCell.gameIsRunning = false
                    sceneManager.presentScene(.CurrentVirusedLevel)
            case .NextLevel_EndLevelView:
                    sceneManager.presentScene(.NextVirusedLevel)
            case .CancelLoop :
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    ActionCell.deselectAll()
                })
            case .ReadyLoop :
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    ActionCell.moveCellsDownWhenAddingRect()
                    ActionCell.deselectAll(self.self.loopControl.numberOfRepeats)
                })
            default:
                break
            }
        }

    }
    
    override func didBeginContact(contact: SKPhysicsContact) {
        let contactMask: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
        case PhysicsCategory.Robot | PhysicsCategory.Detail:
            if (!robot.track!.virused) {

                detail.hideDetail()
                robot.takeDetail()
                runAction(SKAction.sequence([SKAction.waitForDuration(1.5), SKAction.runBlock() {
                        self.sceneManager.virusedGameProgressManager.writeResultOfCurrentLevel(ActionCell.cellsCount())
                    
                    self.overlay = EndLevelView(levelInfo: self.levelInfo, result: ActionCell.cellsCount()) } ]))
                if (ActionCell.cellsCount() <= self.levelInfo.goodResult) {
                    GameViewController.sendAchievementProgress(.Perfection1)
                    let goodLevelsNumber = NSUserDefaults.standardUserDefaults().integerForKey(kNumberOfGoodLevels)
                    NSUserDefaults.standardUserDefaults().setInteger(goodLevelsNumber + 1, forKey: kNumberOfGoodLevels)
                    if (goodLevelsNumber + 1 == 5) {
                        GameViewController.sendAchievementProgress(.Perfection5)
                    }
                    else if (goodLevelsNumber + 1 == 10) {
                        GameViewController.sendAchievementProgress(.Perfection10)
                    }
                    else if (goodLevelsNumber + 1 == 20) {
                        GameViewController.sendAchievementProgress(.Perfection20)
                        
                    }
                }
            }
            else {
                print("you cant take detail on virused track")
            }
        default:
            return
        }
    }


    
    
    
}
