//
//  LevelScene.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 28.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class LevelScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    let background = SKNode()
    let trackLayer = SKNode()
    var touchesToRecord: [String] = []
    //level info
    let thisLevelNumber: Int?
    let thisLevelPackNumber: Int?
    
    let levelBackground1 = SKSpriteNode(imageNamed: "levelBackground1")
    let levelBackground2 = SKSpriteNode(imageNamed: "levelBackground2")
    
    let button_Pause = GameButton(type: .Pause)
    let button_Restart = GameButton(type: .Restart)
    let button_Tips = GameButton(type: .Tips)
    let button_Start = GameButton(type: .Start)
    let button_Debug = GameButton(type: .Debug)
    let button_Clear = GameButton(type: .Clear)
    
    var robot: Robot
    var detail: Detail
    var track: RobotTrack
    
    var selectedNode: SKNode?
    
    let playAreaSize: CGSize
    var canScaleBackground = true
    
    override init(size: CGSize) {
        track = RobotTrack()
        detail = Detail(track: track)
        robot = Robot(track: track, detail: detail)
        
        playAreaSize = CGSize(width: size.width - levelBackground2.size.width, height: size.height)
        thisLevelNumber = GameProgress.sharedInstance.getCurrentLevelNumber()
        thisLevelPackNumber = GameProgress.sharedInstance.getCurrentLevelPackNumber()
        
        super.init(size: size)
        
        //Listening to notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"finishWithSuccess" , name: NotificationKeys.kRobotTookDetailNotificationKey, object: robot)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishWithMistake", name: NotificationKeys.kPauseQuitNotificationKey, object: NotificationZombie.sharedInstance)
    }
    
    //Handling notifications
    
     func finishWithSuccess() {
        print("Finished")
        //record
        var strings : [String!] = []
        for cell in ActionCell.cells {
            strings.append(cell.getActionType().rawValue)
            print(cell.getActionType().rawValue)
        }
        let runtime = TimerDelegate.sharedTimerDelegate.stopAndReturnTime()
       CoreDataAdapter.sharedAdapter.addNewLevel(thisLevelNumber!, levelPackNumber: thisLevelPackNumber!, finished: true, time: runtime, actions: strings, touchedNodes: TouchesAnalytics.sharedInstance.getNodes())
        TouchesAnalytics.sharedInstance.resetTouches()
    }
    
    func finishWithMistake() {
        print("Mistake")
        TimerDelegate.sharedTimerDelegate.stopAndReturnTime()
        //record
        var strings : [String!] = []
        for cell in ActionCell.cells {
            strings.append(cell.getActionType().rawValue)
            print(cell.getActionType().rawValue)
        }
        let runtime = TimerDelegate.sharedTimerDelegate.stopAndReturnTime()
        CoreDataAdapter.sharedAdapter.addNewLevel(thisLevelNumber!, levelPackNumber: thisLevelPackNumber!, finished: false, time: runtime, actions: strings, touchedNodes: TouchesAnalytics.sharedInstance.getNodes())
        TouchesAnalytics.sharedInstance.resetTouches()
    }
    
    func handleTouch(notification : NSNotification) {
        touchesToRecord.append(notification.userInfo!["touch"]! as! String)
        print(notification.userInfo!["touch"]!)
    }
    
    override func didMoveToView(view: SKView) {
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
        
        if GameProgress.sharedInstance.getTutorialNumber() > 0 {
            let number = GameProgress.sharedInstance.getTutorialNumber()
            addChild(Tutorial(tutorialNumber: number))
            
            GameProgress.sharedInstance.removeTutorial()
        }
    }
    
    func createBlocks() {
        let blocksPattern = track.getBlocksPattern()
        
        for var i = 1; i < blocksPattern.count; i++ {
            for var j = 0; j < blocksPattern[i].rawValue; j++ {
                trackLayer.addChild(track.getBlockAt(i, floorPosition: j))
            }
        }
    }
    
    func createTrackLayer() {
        createBlocks()
        trackLayer.addChild(robot)
        trackLayer.addChild(detail)
        background.addChild(trackLayer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handlePinchFrom(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Began {
            canScaleBackground = playAreaSize.width > track.trackLength(1) ? false : true
        } else {
            if recognizer.state == .Changed && canScaleBackground {
                let minScale: CGFloat = playAreaSize.width / track.trackLength(1)
                let maxScale: CGFloat = 1
                
                var deltaScale = recognizer.scale
                let currentScale = trackLayer.xScale
                let zoomSpeed: CGFloat = 0.2
                
                deltaScale = (deltaScale - 1) * zoomSpeed + 1;
                
                deltaScale =  min(deltaScale, maxScale / currentScale);
                deltaScale = max(deltaScale, minScale / currentScale);
                
                trackLayer.runAction(SKAction.scaleBy(deltaScale, duration: 0))
                trackLayer.position = boundLayerPos(trackLayer.position)
                recognizer.scale = 1
                //Analytics->record zoomPinch
                //touchesToRecord.append("zoomPinch")
                TouchesAnalytics.sharedInstance.appendTouch("zoomPinch")
                //print("zoomPinch")
            }
        }
    }
    
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = convertPointFromView(touchLocation)
            
            if track.trackLength(trackLayer.xScale) > playAreaSize.width {
                selectNodeForTouch(touchLocation)
            }
            
        } else if recognizer.state == .Changed && selectedNode != nil {
            var translation = recognizer.translationInView(recognizer.view!)
            translation = CGPoint(x: translation.x, y: -translation.y)
            
            panForTranslation(translation)
            
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        } else if recognizer.state == .Ended && selectedNode != nil {
            let scrollDuration = 0.1
            let velocity = recognizer.velocityInView(recognizer.view)
            let pos = trackLayer.position
            
            let p = CGPoint(x: velocity.x * CGFloat(scrollDuration), y: velocity.y * CGFloat(scrollDuration))
            
            var newPos = CGPoint(x: pos.x + p.x, y: pos.y + p.y)
            newPos = boundLayerPos(newPos)
            trackLayer.removeAllActions()
            
            let moveTo = SKAction.moveTo(newPos, duration: scrollDuration)
            moveTo.timingMode = .EaseOut
            trackLayer.runAction(moveTo)
            selectedNode = nil
            //Analytics->record scrollPan
            //touchesToRecord.append("scrollPan")
            TouchesAnalytics.sharedInstance.appendTouch("scrollPan")
            //print("scrollPan")
        }
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        let touchedNode = nodeAtPoint(touchLocation)
        if levelBackground1.containsPoint(touchLocation) && !levelBackground2.containsPoint(touchLocation) && !touchedNode.isMemberOfClass(GameButton) && !touchedNode.isMemberOfClass(Robot) && !touchedNode.isMemberOfClass(ActionButton) && !touchedNode.isMemberOfClass(SKLabelNode) {
            selectedNode = trackLayer
            trackLayer.removeAllActions()
        } else {
            selectedNode = nil
        }
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = trackLayer.position
        let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        trackLayer.position = boundLayerPos(aNewPosition)
    }
    
    func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
        var retval = aNewPosition
        
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(track.trackLength(trackLayer.xScale)) + playAreaSize.width))
        retval.y = position.y
    
        return retval
    }
    
    func swipedLeft(swipe: UISwipeGestureRecognizer) {
        
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)
        
        if let cell = node as? ActionCell {
            if robot.isOnStart {
                ActionCell.deleteCell(Int(cell.name!)!, direction: .ToLeft)
                //Analytics->record deleteCellSwipeRight
                //touchesToRecord.append("deleteCellSwipeLeft")
                TouchesAnalytics.sharedInstance.appendTouch("deleteCellSwipeLeft")
                //print("deleteCellSwipeRight")
            }
        }

        if let tutorial = node as? Tutorial {
            tutorial.showNextSlide(.ToLeft)
            //Analytics->record showNextSlideSwipe
            //touchesToRecord.append("showNextTutorialSlideSwipe")
            TouchesAnalytics.sharedInstance.appendTouch("showNextTutorialsSlideSwipe")
            //print("showNextTutorialSlideSwipe")
        }
    }
    
    func swipedRight(swipe: UISwipeGestureRecognizer) {
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)

        if let cell = node as? ActionCell {
            if robot.isOnStart {
                ActionCell.deleteCell(Int(cell.name!)!, direction: .ToRight)
                //Analytics->record deleteCellSwipeRight
                //touchesToRecord.append("deleteCellSwipeRight")
                TouchesAnalytics.sharedInstance.appendTouch("deleteCellSwipeRight")
                //print("deleteCellSwipeRight")
            }
        }
        
        if let tutorial = node as? Tutorial {
            tutorial.showNextSlide(.ToRight)
            //Analytics->record showNextSlideSwipe
            //touchesToRecord.append("showNextTutorialSlideSwipe")
            TouchesAnalytics.sharedInstance.appendTouch("showNextTutorialsSlideSwipe")
            //print("showNextTutorialSlideSwipe")
        }
    }
    
    func swipedUp(swipe: UISwipeGestureRecognizer) {
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)
        if node.isMemberOfClass(ActionCell) && node.alpha > 0 && !robot.isRunningActions() {
            ActionCell.moveCellsLayerUp()
            //Analytics->record swipeCellLayerUp
            //touchesToRecord.append("swipeCellLayerUp")
            TouchesAnalytics.sharedInstance.appendTouch("swipeCellLayerUp")
            //print("swipeCellLayerUp")
        }
    }
    
    func swipedDown(swipe: UISwipeGestureRecognizer) {
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)
        if node.isMemberOfClass(ActionCell) && node.alpha > 0 && !robot.isRunningActions() {
            ActionCell.moveCellsLayerDown()
            //Analytics->record swipeCellLayerDown
            //touchesToRecord.append("swipeCellLayerDown")
            TouchesAnalytics.sharedInstance.appendTouch("swipeCellLayerDown")
            //print("swipeCellLayerDown")
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
        case PhysicsCategory.Robot | PhysicsCategory.Detail:
            detail.hideDetail()
            robot.takeDetail()
            if detail.getDetailType() != DetailType.Crystall {
                GameProgress.sharedInstance.checkDetailCellState()
            }
            runAction(SKAction.sequence([SKAction.waitForDuration(1.5), SKAction.runBlock() { self.addChild(EndLevelView()) } ]))
        default:
            return
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            if robot.isTurnedToFront() && !node.isMemberOfClass(ActionCell) {
                robot.runAction(robot.turnFromFront())
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            //touchesToRecord.append(node.name!)
            if let name = node.name {
                TouchesAnalytics.sharedInstance.appendTouch(name)
            }
            //print(node.name!)
            switch node {
            case button_Start:
                checkRobotPosition()
                //Analytics->record start button
                robot.performActions()
            case button_Pause:
                //Analytics->record pause
                pauseGame()
            case button_Tips:
                //Analytics->record tips
                if !robot.isRunningActions() {
                    addChild(Tutorial(tutorialNumber: 0))
                }
            case button_Clear:
                enumerateChildNodesWithName("clear") {
                    node, stop in
                    node.removeFromParent()
                }
                
                ActionCell.resetCellTextures()
                track.deleteBlocks()
                detail.removeFromParent()
                robot.removeFromParent()
                trackLayer.removeFromParent()
                track = RobotTrack()
                detail = Detail(track: track)
                robot = Robot(track: track, detail: detail)
                
                createTrackLayer()
                //Analytics->record clear button
            case button_Debug:
                //Analytics->record debug button
                robot.debug()
            case button_Restart:
                //Analytics-->record Restart button
                weak var view = self.view
                GameProgress.sharedInstance.newGame(view!)
            default:
                return
            }
        }
    }
    
    func createBackground() {
        levelBackground1.anchorPoint = CGPointZero
        levelBackground1.zPosition = -1
        background.addChild(levelBackground1)
        background.name = "background"
        levelBackground2.anchorPoint = CGPointZero
        levelBackground2.position = CGPoint(x: size.width - levelBackground2.size.width, y: 0)
        levelBackground2.zPosition = 1000
        background.addChild(levelBackground2)
        
        addChild(background)
        
        background.addChild(createLabel("Программа", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1773, y: 1429)))
        button_Debug.addChild(createLabel("Отладка", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        button_Start.addChild(createLabel("Запуск", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        button_Clear.addChild(createLabel("В начало", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        button_Restart.addChild(createLabel("Заново", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        background.addChild(createLabel("ПОСЛЕ ЗАПУСКА", fontColor: UIColor.whiteColor(), fontSize: 23, position: CGPoint(x: 1773, y: 1296)))
        
        addChild(button_Pause)
        button_Pause.zPosition = 3001
        addChild(button_Start)
        addChild(button_Tips)
        addChild(button_Restart)
        addChild(button_Debug)
        addChild(button_Clear)
    }
    
    func pauseGame() {
        background.paused = true
        let pauseView = PauseView()
        addChild(pauseView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func checkRobotPosition(durationOfAnimation: NSTimeInterval = 0.4) {
        let bound: CGFloat = Constants.BlockFace_Size.width
        let robotPosition = trackLayer.position.x + robot.position.x
        
        if robotPosition < bound {
            trackLayer.runAction(SKAction.moveByX(-robotPosition + bound, y: 0, duration: durationOfAnimation))
            return
        }
        
        if robotPosition > playAreaSize.width - bound {
            trackLayer.runAction(SKAction.moveByX(-robotPosition + playAreaSize.width - bound, y: 0, duration: durationOfAnimation))
        }
    }
    
    func showDetailAndRobot() {
        let bound: CGFloat = Constants.BlockFace_Size.width
        let detailPosition = trackLayer.position.x + detail.position.x
        
        if detailPosition < bound {
            trackLayer.runAction(SKAction.moveByX(-detailPosition + bound, y: 0, duration: 0), completion: { self.checkRobotPosition() })
            return
        }
        
        if detailPosition > playAreaSize.width - bound {
            trackLayer.runAction(SKAction.moveByX(-detailPosition + playAreaSize.width - bound, y: 0, duration: 0), completion: { self.checkRobotPosition() })
            return
        }
        
        checkRobotPosition()
    }
    
    func addGestures() {
        weak var view = self.view
        if let count = view!.gestureRecognizers?.count {
            if count > 0 {
                view!.gestureRecognizers?.removeAll(keepCapacity: false)
            }
        }

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        swipeLeft.delegate = self
        view!.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
        swipeRight.direction = .Right
        swipeRight.delegate = self
        view!.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        swipeUp.delegate = self
        view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        swipeDown.delegate = self
        view!.addGestureRecognizer(swipeDown)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
        view!.addGestureRecognizer(gestureRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchFrom:"))
        view!.addGestureRecognizer(pinchRecognizer)
    }
    
    override func update(currentTime: CFTimeInterval) {
        if robot.isRunningActions() {
            checkRobotPosition(0)
        }
    }
}