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
    
    let levelBackground1 = SKSpriteNode(imageNamed: "levelBackground1")
    let levelBackground2 = SKSpriteNode(imageNamed: "levelBackground2")
    
    let button_Pause = GameButton(type: .Pause)
    let button_Restart = GameButton(type: .Restart)
    let button_Tips = GameButton(type: .Tips)
    let button_Start = GameButton(type: .Start)
    let button_Debug = GameButton(type: .Debug)
    let button_Clear = GameButton(type: .Clear)
    
    var robot: Robot?
    var detail: Detail?
    var track: RobotTrack?
    
    var selectedNode: SKNode?
    
    let levelData: [String : AnyObject]
    
    private var blocksPattern: [FloorPosition] = []
    
    let playAreaSize: CGSize
    var canScaleBackground = true
    
    override init(size: CGSize) {
        levelData = GameProgress.sharedInstance.getCurrentLevelData()
        playAreaSize = CGSize(width: size.width - levelBackground2.size.width, height: size.height)
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        userInteractionEnabled = true
        anchorPoint = CGPointZero
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        ActionCell.cellsLayer.removeFromParent()
        addChild(ActionCell.cellsLayer)
        ActionCell.resetCells()
        
        ActionCell.cells.removeAll(keepCapacity: false)
        
        createBackground()
        createTrackLayer()
        
        if let count = view.gestureRecognizers?.count {
            if count > 0 {
                view.gestureRecognizers?.removeAll(keepCapacity: false)
            }
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        swipeLeft.delegate = self
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        swipeUp.delegate = self
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        swipeDown.delegate = self
        view.addGestureRecognizer(swipeDown)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
        view.addGestureRecognizer(gestureRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchFrom:"))
        view.addGestureRecognizer(pinchRecognizer)
        
        showDetailAndRobot()
    }
    
    func createBlocks() {
        if track?.deleteBlocks() != nil {
            track!.deleteBlocks()
        }
        
        track = RobotTrack(pattern: blocksPattern, robotPosition: robot!.getStartPosition(), detailPosition: detail!.getTrackPosition())
        robot!.track = track!
        for var i = 1; i <= blocksPattern.count; i++ {
            for var j = 0; j < blocksPattern[i - 1].rawValue; j++ {
                trackLayer.addChild(track!.getBlockAt(i, floorPosition: j))
            }
        }
    }
    
    func createTrackLayer() {
        let blocks: AnyObject? = levelData["blocksPattern"]
        if let pattern = blocks as? [Int] {
            for block in pattern {
                if let floor = FloorPosition(rawValue: block) {
                    blocksPattern.append(floor)
                }
            }
        }
        
        let robotPosition = levelData["robotPosition"] as! Int
        let detailPosition = levelData["detailPosition"] as! Int
        
        let detailFloorPositionInt = levelData["detailFloorPosition"] as! Int
        let detailFloorPosition = FloorPosition(rawValue: detailFloorPositionInt)
        
        track = RobotTrack(pattern: blocksPattern, robotPosition: robotPosition, detailPosition: detailPosition)
        
        robot = Robot(track: track!)
        
        let detailTypeString  = levelData["detailType"] as! String
        if let detailType = DetailType(rawValue: detailTypeString) {
            detail = Detail(detailType: detailType, trackPosition: detailPosition, floorPosition: detailFloorPosition!)
        }
        
        trackLayer.addChild(robot!)
        trackLayer.addChild(detail!)

        for var i = 1; i <= blocksPattern.count; i++ {
            for var j = 0; j < blocksPattern[i - 1].rawValue; j++ {
                trackLayer.addChild(track!.getBlockAt(i, floorPosition: j))
            }
        }
        
        background.addChild(trackLayer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handlePinchFrom(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Began {
            canScaleBackground = playAreaSize.width > track!.trackLength(1) ? false : true
        } else {
            if recognizer.state == .Changed && canScaleBackground {
                let minScale: CGFloat = playAreaSize.width / track!.trackLength(1)
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
            }
        }
    }
    
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = convertPointFromView(touchLocation)
            
            if track!.trackLength(trackLayer.xScale) > playAreaSize.width {
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
        retval.x = CGFloat(max(retval.x, -(track!.trackLength(trackLayer.xScale)) + playAreaSize.width))
        retval.y = position.y
    
        return retval
    }
    
    func swipedLeft(swipe: UISwipeGestureRecognizer) {
        if robot!.isOnStart {
            let touchLocation = convertPointFromView(swipe.locationInView(view))
            let node = nodeAtPoint(touchLocation)
            if let cell = node as? ActionCell {
                ActionCell.deleteCell(Int(cell.name!)!)
            } else if let cell = node.parent! as? ActionCell {
                ActionCell.deleteCell(Int(cell.name!)!)
            }
        }
    }
    
    func swipedUp(swipe: UISwipeGestureRecognizer) {
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)
        if node.isMemberOfClass(ActionCell) && node.alpha > 0 && !robot!.isRunningActions() {
            ActionCell.moveCellsLayerUp()
        }
    }
    
    func swipedDown(swipe: UISwipeGestureRecognizer) {
        let touchLocation = convertPointFromView(swipe.locationInView(view))
        let node = nodeAtPoint(touchLocation)
        if node.isMemberOfClass(ActionCell) && node.alpha > 0 && !robot!.isRunningActions() {
            ActionCell.moveCellsLayerDown()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
        case PhysicsCategory.Robot | PhysicsCategory.Detail:
            detail!.hideDetail()
            robot!.takeDetail()
            
            if detail!.getDetailType() != DetailType.Crystall {
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
            switch node {
            case button_Start, button_Pause, button_Tips, button_Debug, button_Restart, button_Clear:
                return
            default:
                if robot!.isTurnedToFront() && !node.isMemberOfClass(ActionCell) {
                    robot!.runAction(robot!.turnFromFront())
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            switch node {
            case button_Start:
                checkRobotPosition()
                robot!.performActions()
            case button_Pause:
                pauseGame()
            case button_Tips:
                GameProgress.sharedInstance.goToMenu(view!)
            case button_Clear:
                ActionCell.resetCellTextures()
                robot!.resetActions()
                createBlocks()
            case button_Debug:
                robot!.debug()
            case button_Restart:
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
        
        levelBackground2.anchorPoint = CGPointZero
        levelBackground2.position = CGPoint(x: size.width - levelBackground2.size.width, y: 0)
        levelBackground2.zPosition = 1000
        background.addChild(levelBackground2)
        
        addChild(background)
        
        background.addChild(createLabel("Программа", fontColor: UIColor.blackColor(), fontSize: 46, position: CGPoint(x: 1773, y: 1429)))
        background.addChild(createLabel("По одной", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1648, y: 390)))
        background.addChild(createLabel("Запуск", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1769, y: 217)))
        background.addChild(createLabel("В начало", fontColor: UIColor.blackColor(), fontSize: 29, position: CGPoint(x: 1892, y: 390)))
        background.addChild(createLabel("ПОСЛЕ ЗАПУСКА", fontColor: UIColor.whiteColor(), fontSize: 23, position: CGPoint(x: 1773, y: 1296)))
        
        addChild(button_Pause)
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
        let robotPosition = trackLayer.position.x + robot!.position.x
        
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
        let detailPosition = trackLayer.position.x + detail!.position.x
        
        if detailPosition < bound {
            trackLayer.runAction(SKAction.moveByX(-detailPosition + bound, y: 0, duration: 0), completion: { self.checkRobotPosition() })
            return
        }
        
        if detailPosition > playAreaSize.width - bound {
            trackLayer.runAction(SKAction.moveByX(-detailPosition + playAreaSize.width - bound, y: 0, duration: 0), completion: { self.checkRobotPosition() })
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if robot!.isRunningActions() {
            checkRobotPosition(0)
        }
    }
}