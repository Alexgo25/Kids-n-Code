//
//  MenuScene.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 28.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit
import Google
import GameKit

let kRobotFirstTextImageName = NSLocalizedString("First_Text", comment: "first text")
let kDetailTextSuffix = NSLocalizedString("DetailTextSuffix", comment: "Detail text suffix")
let kFinalViewImageName = NSLocalizedString("finalView", comment: "Final view")
let kVirusedPreviewWasShown = "virusedPreviewWasShown"

class MenuScene: SceneTemplate  {
    
    let background = SKSpriteNode(imageNamed: "menuBackground")
    let textString: String
    
    let keyboard = SKSpriteNode(imageNamed: "keyboard")
    let screen = SKSpriteNode(imageNamed: "activeScreen")
    let finalView = SKSpriteNode(imageNamed: kFinalViewImageName)
    let pauseButton = GameButton(type: .MenuPause)
    let enterButton = GameButton(type: .Enter)
    
    let data: [LevelPackData]
    var details: [DetailCell] = []
    
    override var overlay: SKSpriteNode? {
        willSet {
            if let overlay = overlay as? MenuPauseView {
                background.paused = false
                overlay.hide()
            }
            
            if let overlay = overlay as? Tutorial {
                overlay.hide()
            }
            else {
                print(overlay)
            }
        }
    }
    
    init(robotTextImage: String = kRobotFirstTextImageName, data: [LevelPackData]) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "MainMenu")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        textString = robotTextImage
        self.data = data
        
        super.init()
        
        background.anchorPoint = CGPointZero
        background.zPosition = -1
        addChild(background)
        
        keyboard.zPosition = 1010
        keyboard.anchorPoint = CGPoint(x: 1, y: 1)
        keyboard.position = CGPoint(x: 758, y: 523)
        addChild(keyboard)
        addChild(pauseButton)
        //addChild(enterButton)
        
            //temporary for testing
        
            screen.anchorPoint = CGPoint(x: 1, y: 1)
            screen.zPosition = 1010
            screen.alpha = 1
            screen.position = CGPoint(x: 1899, y: 1439)
        
        
        
            //
        
        
        userInteractionEnabled = true
    }
    
    override func didMoveToView(view: SKView) {
        
        if let _ = view.gestureRecognizers {
            view.gestureRecognizers!.removeAll(keepCapacity: false)
        }
        
        showDetails()
        
        if sceneManager.gameProgressManager.finished() {
            turnOnScreenAndMoveKeyboard()
            runAction(SKAction.waitForDuration(1.0), completion: { self.showVirusingSlides()
                } )
        } else {
            showRobot(textString)
        }
        if (sceneManager.gameProgressManager.isGameFinished()) {
            if (screen.parent == nil) {
                addChild(screen)
            }
            if (NSUserDefaults.standardUserDefaults().objectForKey(kVirusedPreviewWasShown) == nil) {
                showVirusingSlides()
            }
            
        }
        //showVirusingSlides()
        //showGarland()
    }
    /*
    func showGarland() {
        let garlandTexture = SKTexture(imageNamed: "garland1")
        let garland = SKSpriteNode(texture: garlandTexture)
        garland.anchorPoint = CGPointZero
        garland.position = CGPoint(x: 808, y: 1369)
        addChild(garland)
        
        let garlandTexture2 = SKTexture(imageNamed: "garland2")
        let action1 = SKAction.setTexture(garlandTexture2)
        let action2 = SKAction.setTexture(garlandTexture)
        
        let sequence = SKAction.sequence([SKAction.waitForDuration(1.5), action1, SKAction.waitForDuration(1.5), action2])
        garland.runAction(SKAction.repeatActionForever(sequence))
    }
    */
    
    func showVirusingSlides() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("Finished") as? Bool == true {
            defaults.removeObjectForKey("Finished")
        }
        defaults.setBool(true, forKey: kVirusedPreviewWasShown)
        overlay = Tutorial(tutorialNumber: -1)
    }
    func showFinalView() {
        finalView.zPosition = 10000
        finalView.anchorPoint = CGPointZero
        finalView.alpha = 0
        addChild(self.finalView)
        finalView.runAction(SKAction.fadeInWithDuration(0.4))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            
            if let cell = nodeAtPoint(touchLocation) as? DetailCell {
                switch cell.cellState {
                case .Active, .Placed:
                    AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
                    let levels = data[cell.index].levels
                    overlay = LevelSelectionView(levelPackIndex: cell.index, levels: levels)
                case .NonActive:
                    return
                }
            } else if nodeAtPoint(touchLocation) == finalView {
                finalView.runAction(SKAction.fadeOutWithDuration(0.4), completion: { self.finalView.removeFromParent() } )
                turnOffScreenAndMoveKeyboard()
                
                let currentLevelPackIndex = sceneManager.levelPacksInfo.count - 1
                let currentLevelPackData = data[currentLevelPackIndex]
                showRobot("\(currentLevelPackData.detailType)" + kDetailTextSuffix)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if defaults.objectForKey("Finished") as? Bool == true {
                    defaults.removeObjectForKey("Finished")
                }
            }
            
            else if nodeAtPoint(touchLocation) == screen {
                sceneManager.presentScene(.VirusedMenu)
            }
        }
    }
    
    func showDetails() {
        for levelPack in data {
            let detailCell = DetailCell(detailType: levelPack.detailType, cellState: levelPack.cellState, index: details.count)
            details.append(detailCell)
            addChild(detailCell)
        }
    }
    
    func showRobot(var textImageString: String = kRobotFirstTextImageName) {
        let texture = SKTexture(imageNamed: "menuRobot")
        let robot = SKSpriteNode(texture: texture)
        robot.anchorPoint = CGPointZero
        robot.position = CGPoint(x: 1542.5, y: -726)
        let move = SKAction.sequence([SKAction.waitForDuration(0.4), SKAction.moveByX(0, y: 410, duration: 0.5), SKAction.moveByX(0, y: -62, duration: 0.13)])
        addChild(robot)
        robot.runAction(move)
        robot.zPosition = 2
        
        let stick = SKSpriteNode(imageNamed: "stick")
        stick.position = CGPoint(x: 18.5, y: 580)
        robot.addChild(stick)
        
        if sceneManager.gameProgressManager.isGameFinished() && textImageString == kRobotFirstTextImageName {
            textImageString.appendContentsOf("_Final")
        }
        
        let label = SKSpriteNode(imageNamed: textImageString)
        
        label.anchorPoint = CGPoint(x: 1, y: 0.4)
        label.position = CGPoint(x: -18.5, y: 580)
        label.zPosition = 2
        robot.addChild(label)
    }
    
    func turnOnScreenAndMoveKeyboard() {
        if (screen.parent == nil) {
            addChild(screen)
        }
        //keyboard.runAction(SKAction.moveTo(CGPoint(x: 1821, y: 1169), duration: 1), completion: {        self.screen.runAction(SKAction.fadeInWithDuration(0.75)) } )
    }
    
    func turnOffScreenAndMoveKeyboard() {
        screen.runAction(SKAction.fadeOutWithDuration(0.5), completion: { self.screen.removeFromParent() } )
        keyboard.runAction(SKAction.moveTo(CGPoint(x: 758, y: 523), duration: 1))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    override func buttonPressed(button: ButtonNode) {
        if let gameButton = button as? GameButton {
            switch gameButton.gameButtonType {
            case .MenuPause:
                overlay = MenuPauseView()
            case .Continue_PauseView:
                overlay = nil
            case .Enter:
                sceneManager.presentScene(.VirusedMenu)
            case .Achievements_PauseView:
                NSNotificationCenter.defaultCenter().postNotificationName(kShowGameCenterLeaderboard, object: NotificationZombie.sharedInstance)
            default:
                break
            }
        }
    }
    
}
