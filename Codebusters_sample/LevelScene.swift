//
//  LevelScene.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 28.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit
import Google

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Robot: UInt32 = 0b1  // 1
    static let Detail: UInt32 = 0b10  // 2
}
//Button labels
let kStartButtonLabel = NSLocalizedString("START_BUTTON_LABEL", comment: "Start button label")
let kDebugButtonLabel = NSLocalizedString("DEBUG_BUTTON_LABEL", comment: "Debug button label")
let kReturnButtonLabel = NSLocalizedString("RETURN_BUTTON_LABEL", comment: "Return button label")
let kRestartButtonLabel = NSLocalizedString("RESTART_BUTTON_LABEL", comment: "Restart button label")
//Other labels
let kProgramLabel = NSLocalizedString("PROGRAM_LABEL", comment: "Program label top-right")
let kOnstartLabel = NSLocalizedString("ONSTART_LABEL", comment: "ON Start label below the program")
let kNumberOfRepeatsLabel = NSLocalizedString("NUMBER_OF_REPEATS_LABEL", comment: "Number of repeats for the loop")


class LevelScene: SceneTemplate, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    let levelInfo: LevelConfiguration
    
    let background = SKNode()
    let trackLayer = SKNode()
    var touchesToRecord: [String] = []
    
    var levelBackground1 = SKSpriteNode(imageNamed: "virusedBackground")
    var levelBackground2 = SKSpriteNode(imageNamed: "virusedBackground_2")
    
    var button_Pause : GameButton!
    var button_Restart : GameButton!
    var button_Tips : GameButton!
    var button_Start : GameButton!
    var button_Debug : GameButton!
    var button_Clear : GameButton!
    var button_ReadyLoop : GameButton!
    var button_CancelLoop : GameButton!
    var loopControl = LoopControlFullRect()
    
    var robot: Robot
    var detail: Detail
    var track: RobotTrack
    
    var selectedNode: SKNode?
    
    var playAreaSize: CGSize!
    var canScaleBackground = true
    
    override var overlay: SKSpriteNode? {
        willSet {
            if let overlay = overlay as? PauseView {
                background.paused = false
                overlay.hide()
            }
            
            if ((newValue?.isMemberOfClass(EndLevelView)) != nil) {
                background.paused = false
            }
            
            if let overlay = overlay as? Tutorial {
                overlay.hide()
            }
            else {
                print(overlay)
            }
        }
    }
    
    init(levelInfo: LevelConfiguration) {
        self.levelInfo = levelInfo
        track = RobotTrack(levelInfo: levelInfo)
        detail = Detail(track: track, levelInfo: levelInfo)
        robot = Robot(track: track, detail: detail)
        super.init()
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Level Scene")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        //Listening to notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"finishWithSuccess" , name:kRobotTookDetailNotificationKey, object: robot)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishWithMistake", name: kPauseQuitNotificationKey, object: NotificationZombie.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addNewControls", name: kActionCellSelectedKey, object: NotificationZombie.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeNewControls", name: kActionCellDeselectAllKey, object: NotificationZombie.sharedInstance)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kNeedUpdatesKey)
        //Game buttons
        createGameButtons()
    }
    
    //Handling notifications
    
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
    
    func createGameButtons(){
         button_Pause = GameButton(type: .Pause)
         button_Restart = GameButton(type: .Restart)
         button_Tips = GameButton(type: .Tips)
         button_Start = GameButton(type: .Start)
         button_Debug = GameButton(type: .Debug)
         button_Clear = GameButton(type: .Clear)
         button_ReadyLoop = GameButton(type: .ReadyLoop)
         button_CancelLoop = GameButton(type: .CancelLoop)
        createLabel(kNumberOfRepeatsLabel, fontColor: UIColor.blackColor(), fontSize: 28.56, position: CGPoint(x: 1800, y: 412))
    }
    
    func finishWithSuccess() {
        print("Finished")
        //record
        var strings : [String!] = []
        for cell in ActionCell.cells {
            strings.append(cell.actionType.rawValue)
            print(cell.actionType.rawValue)
        }
        let runtime = TimerDelegate.sharedTimerDelegate.stopAndReturnTime()
        CoreDataAdapter.sharedAdapter.addNewLevel(sceneManager.currentLevel , levelPackNumber: sceneManager.currentLevelPack, finished: true, time: runtime, actions: strings, touchedNodes: TouchesAnalytics.sharedInstance.getNodes())
        TouchesAnalytics.sharedInstance.resetTouches()
    }
    
    func finishWithMistake() {
        print("Mistake")
        TimerDelegate.sharedTimerDelegate.stopAndReturnTime()
        //record
        var strings : [String!] = []
        for cell in ActionCell.cells {
            strings.append(cell.actionType.rawValue)
            print(cell.actionType)
        }
        let runtime = TimerDelegate.sharedTimerDelegate.stopAndReturnTime()
        CoreDataAdapter.sharedAdapter.addNewLevel(sceneManager.currentLevel, levelPackNumber: sceneManager.currentLevelPack, finished: false, time: runtime, actions: strings, touchedNodes: TouchesAnalytics.sharedInstance.getNodes())
        TouchesAnalytics.sharedInstance.resetTouches()
    }
    
    func handleTouch(notification : NSNotification) {
        touchesToRecord.append(notification.userInfo!["touch"]! as! String)
        print(notification.userInfo!["touch"]!)
    }
    
    
    
    override func didMoveToView(view: SKView) {
        let size = sceneManager.size
        playAreaSize = CGSize(width: size.width - levelBackground2.size.width, height: size.height)
        
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
            sceneManager.gameProgressManager.removeTutorial()
        }
    }
    
    func createBlocks() {
        let blocksPattern = track.getBlocksPattern()
        
        for var i = 1; i < blocksPattern.count; i++ {
            for var j = 0; j < blocksPattern[i].rawValue; j++ {
                trackLayer.addChild(track.getBlockAt(i, floorPosition: j))
            }
        }
        if (levelInfo.virusPosition != -1) {
            track.virused = true
            let virus = LevelVirus(levelcfg: levelInfo, track: track)
            trackLayer.addChild(virus)
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
        
        if (ActionCell.selectedIndexes == []) {
            if let cell = node as? ActionCell {
                if robot.isOnStart {
                    ActionCell.deleteCell(ActionCell.cells.indexOf(cell)!, direction: .ToLeft)
                    //Analytics->record deleteCellSwipeRight
                    //touchesToRecord.append("deleteCellSwipeLeft")
                    TouchesAnalytics.sharedInstance.appendTouch("deleteCellSwipeLeft")
                    //print("deleteCellSwipeRight")
                }
            }
                
            else if let rect = node as? LoopControlRepeatRect {
                if (robot.isOnStart) {
                    ActionCell.deleteRect(ActionCell.repeatRectangles.indexOf(rect)!, direction: .ToLeft)
                    TouchesAnalytics.sharedInstance.appendTouch("deleteRectSwipe")
                }
            }
        }
        
        
        if let parent = node.parent {
            if let parent = parent.parent where parent.isMemberOfClass(Tutorial) {
                if let tutorial = parent as? Tutorial {
                    tutorial.showNextSlide(.ToLeft)
                    //Analytics->record showNextSlideSwipe
                    //touchesToRecord.append("showNextTutorialSlideSwipe")
                    TouchesAnalytics.sharedInstance.appendTouch("showNextTutorialsSlideSwipe")
                    //print("showNextTutorialSlideSwipe")
                }
            }
        }
    }
    
    func swipedRight(swipe: UISwipeGestureRecognizer) {
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)
        if (ActionCell.selectedIndexes == []) {
            if let cell = node as? ActionCell {
                if robot.isOnStart {
                    ActionCell.deleteCell(ActionCell.cells.indexOf(cell)!, direction: .ToRight)
                    //Analytics->record deleteCellSwipeRight
                    //touchesToRecord.append("deleteCellSwipeRight")
                    TouchesAnalytics.sharedInstance.appendTouch("deleteCellSwipeRight")
                    //print("deleteCellSwipeRight")
                }
            }
                
            else if let rect = node as? LoopControlRepeatRect {
                if (robot.isOnStart) {
                    ActionCell.deleteRect(ActionCell.repeatRectangles.indexOf(rect)!, direction: .ToRight)
                    TouchesAnalytics.sharedInstance.appendTouch("deleteRectSwipe")
                }
            }

        }
        
        if let parent = node.parent {
            if let parent = parent.parent where parent.isMemberOfClass(Tutorial) {
                if let tutorial = parent as? Tutorial {
                    tutorial.showNextSlide(.ToRight)
                    //Analytics->record showNextSlideSwipe
                    //touchesToRecord.append("showNextTutorialSlideSwipe")
                    TouchesAnalytics.sharedInstance.appendTouch("showNextTutorialsSlideSwipe")
                    //print("showNextTutorialSlideSwipe")
                }
            }
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
        if ((node.isMemberOfClass(ActionCell) || node.isMemberOfClass(LoopControlRepeatRect)) && node.alpha > 0 && !robot.isRunningActions()) {
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
            if (!robot.track!.virused) {
                detail.hideDetail()
                robot.takeDetail()
                runAction(SKAction.sequence([SKAction.waitForDuration(1.5), SKAction.runBlock() {
                    self.sceneManager.gameProgressManager.writeResultOfCurrentLevel(ActionCell.cellsCount())
                    self.overlay = EndLevelView(levelInfo: self.levelInfo, result: ActionCell.cellsCount()) } ]))
            }
            else {
                print("you cant take detail on virused track")
            }
        default:
            return
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            if robot.isTurnedToFront && !node.isMemberOfClass(ActionCell) {
                robot.runAction(robot.turnFromFront())
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
//markLabels
        background.addChild(createLabel(kProgramLabel, fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1773, y: 1429)))
        button_Debug.addChild(createLabel(kDebugButtonLabel, fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        button_Start.addChild(createLabel(kStartButtonLabel, fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        button_Clear.addChild(createLabel(kReturnButtonLabel, fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        button_Restart.addChild(createLabel(kRestartButtonLabel, fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 0, y: 90)))
        background.addChild(createLabel(kOnstartLabel, fontColor: UIColor.whiteColor(), fontSize: 23, position: CGPoint(x: 1773, y: 1296)))
        
        addChild(button_Pause)
        button_Pause.zPosition = 3001
        addChild(button_Start)
        addChild(button_Tips)
        addChild(button_Restart)
        addChild(button_Debug)
        addChild(button_Clear)
        addChild(button_CancelLoop)
        addChild(button_ReadyLoop)
        addChild(loopControl)
    }
    
    func pauseGame() {
        background.paused = true
        overlay = PauseView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func checkRobotPosition(durationOfAnimation: NSTimeInterval = 0.4) {
        let bound: CGFloat = Block.BlockFaceSize.width
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
        let bound: CGFloat = Block.BlockFaceSize.width
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
    
    override func buttonPressed(button: ButtonNode) {
        if let gameButton = button as? GameButton {
            switch gameButton.gameButtonType {
            case .Start:
                checkRobotPosition()
                robot.performActions()
            case .Pause:
                pauseGame()
            case .Tips:
                if !robot.isRunningActions() {
                    overlay = Tutorial(tutorialNumber: 0)
                }
            case .Clear:
                enumerateChildNodesWithName("clear") {
                    node, stop in
                    node.removeFromParent()
                }
                ActionCell.resetCellTextures()
                track.deleteBlocks()
                detail.removeFromParent()
                robot.removeFromParent()
                trackLayer.removeFromParent()
                track = RobotTrack(levelInfo: levelInfo)
                detail = Detail(track: track, levelInfo: levelInfo)
                robot = Robot(track: track, detail: detail)
                createTrackLayer()
            case .Debug:
                robot.debug()
            case .Continue_PauseView, .Ok:
                overlay = nil
            case .Exit_PauseView, .Exit_EndLevelView:
                NSNotificationCenter.defaultCenter().postNotificationName(kPauseQuitNotificationKey, object: NotificationZombie.sharedInstance)
                sceneManager.presentScene(.Menu)
            case .Restart_PauseView, .Restart_EndLevelView, .Restart:
                sceneManager.presentScene(.CurrentLevel)
            case .NextLevel_EndLevelView:
                sceneManager.presentScene(.NextLevel)
            case .CancelLoop :
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    ActionCell.deselectAll()
                })
            case .ReadyLoop :
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    ActionCell.moveCellsDownWhenAddingRect()
                    ActionCell.deselectAll(self.self.loopControl.numberOfRepeats)
                })
            case .Achievements :
                break
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if robot.isRunningActions() {
            checkRobotPosition(0)
        }
    }
}