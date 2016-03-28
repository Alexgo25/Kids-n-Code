//
//  Robot.swift
//  Codebusters_sample
//
//  Created by Alexander on 01.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

enum Direction: Int {
    case ToRight = 1,
    ToLeft = -1
    
    mutating func toggle() {
        switch self {
        case ToRight:
            self = ToLeft
        case ToLeft:
            self = ToRight
        }
    }
}

class Robot: SKSpriteNode, SKPhysicsContactDelegate {
    let FirstBlockPosition = CGPoint(x: 315, y: 760)
    
    private var actions: [SKAction] = []
    private var currentActionIndex = 0

    
    var direction = Direction.ToRight // рассчитывается заранее
    private var animationDirection = Direction.ToRight // рассчитывается во время движения
    var isTurnedToFront = false
    private var stopRobot = false
    private var robotTookDetail = false
    private var debugging = false
    private var runningActions = false
    private var currentTrackPosition = 0 // рассчитывается во время движения
    private var currentFloorPosition = FloorPosition.First
    
    private weak var detail: Detail?
    weak var track: RobotTrack?
    
    private let actionButtons = [ActionButton(type: .Move), ActionButton(type: .Turn), ActionButton(type: .Push), ActionButton(type: .Jump) , ActionButton(type: .Catch)]
    var isOnStart = true
    
    init(track: RobotTrack, detail: Detail) {
        self.track = track
        self.detail = detail
        
        let texture = SKTexture(imageNamed: "robot")
        super.init(texture: texture, color: SKColor(), size: texture.size())
        
        moveToStart()

        changeZPosition(currentFloorPosition)
        userInteractionEnabled = true
        
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width - 50, height: size.height - 70))
        physicsBody!.categoryBitMask = PhysicsCategory.Robot
        physicsBody!.contactTestBitMask = PhysicsCategory.Detail
        physicsBody!.collisionBitMask = 0
        name = "Robot"
        setScale(0.8)
    }
    
    func isRunningActions() -> Bool {
        return debugging || runningActions
    }
    
    func currentAction() -> Int {
        return currentActionIndex
    }
    
    func canPerformAction(actionType: ActionType) -> Bool {
        return track!.canPerformActionWithDirection(actionType, direction: direction)
    }
    
    func takeDetail() {
            stopRobot = true
            robotTookDetail = true
    }
    
    func appendAction(actionCell : ActionCell) -> Bool {
        if canPerformAction(actionCell.actionType) {
            let highlightBeginAction = actionCell.highlightBegin()
            let highlightEndAction = actionCell.highlightEnd()
            var action: SKAction
            switch actionCell.actionType {
            case .Move:
                action = move()
            case .Turn:
                action = turn()
            case .Jump:
                action = jump(false)
            case .Push:
                action = push()
            case .Catch:
                action = catchVirus()
            default:
                return false
            }
            let sequence = SKAction.sequence([SKAction.runBlock() { self.runningActions = true },  highlightBeginAction,
                action,
                highlightEndAction,
                SKAction.runBlock() { self.runningActions = false }])
            actions.append(sequence)
        } else {
            actions.append(SKAction.runBlock() {
                self.stopRobot = true
            })
            
            actions.append(SKAction())
            return true
        }
        
        return false
    }
    
    func resetActions() {
        moveToStart()
    }

    func startDebugging() {
        if !ActionCell.cells.isEmpty && !stopRobot {
            debugging = true
            
            if isOnStart {
                isOnStart = false
                
                for cell in ActionCell.cells {
                    if appendAction(cell) {
                        break
                    }
                }
                
                ActionCell.moveCellsLayerToTop()
                
                var sequence = [SKAction.runBlock() { self.detail!.fixPosition() }]
                
                if isTurnedToFront {
                    sequence.append(turnFromFront())
                }
                
                sequence.append(SKAction.runBlock() { self.debug() })
                runAction(SKAction.sequence(sequence))
            } else {
                debug()
            }
        }
    }
    
    func debug() {
        if !debugging {
            startDebugging()
        } else {
            if !stopRobot && !runningActions {
                runAction(actions[currentActionIndex], completion: {
                    self.runAction(SKAction.runBlock() {
                        self.checkDetail()
                        //stop robot
                        if self.stopRobot {
                            let turn = SKAction.animateWithTextures(self.getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05, resize: true, restore: false)
                            
                            if self.robotTookDetail {
                                    self.runAction(turn)

                            } else {
                                
                                let sequence = SKAction.sequence([turn, self.mistake()])
                                self.runAction(sequence)
                            }
                        } else {
                            if self.currentActionIndex < self.actions.count - 1 {
                                self.currentActionIndex += 1
                                if self.currentActionIndex > 5 && self.currentActionIndex + 5 < ActionCell.cellsCount() && ActionCell.canMoveCellsLayerUp() {
                                    ActionCell.moveCellsLayerUp()
                                }
                            } else {
                                self.stopRobot = true

                                //let turn = SKAction.animateWithTextures(self.getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05)
                                
                                //self.runAction(turn)
                            }
                        }
                    })
                })
            }
            debugging = false
        }
    }
    
    func checkDetail() {
        if detail!.getFloorPosition() == currentFloorPosition && detail!.getTrackPosition() == currentTrackPosition {
            if (detail!.detailType != .Door) {
                detail!.zPosition -= 1
                detail!.runAction(SKAction.moveByX(0, y: -200, duration: 0.4))
                takeDetail()
                NSNotificationCenter.defaultCenter().postNotificationName(kRobotTookDetailNotificationKey, object: self)
            }
            else {
                
            }
            
        }
    }
    
    func runActions() {
        runAction(actions[currentActionIndex], completion: {
            self.runAction(SKAction.runBlock() {
                self.checkDetail()
                if self.stopRobot {
                    let turn = SKAction.animateWithTextures(self.getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05, resize: true, restore: false)
                
                    
                    if self.robotTookDetail {
                        if (self.detail!.detailType == .Door) {
                            self.removeAllActions()
                            self.runAction(self.fadeOutInTheDoor())
                        }
                        else {
                            self.runAction(turn)
                        }
                    } else {
                        let sequence = SKAction.sequence([turn, self.mistake()])
                        self.runAction(sequence)
                        self.lightClearButton()
                    }
                    
                    return
                } else {
                    if self.currentActionIndex < self.actions.count - 1 {
                        self.currentActionIndex += 1

                        if self.currentActionIndex > 5 && self.currentActionIndex + 5 < ActionCell.cellsCount() && ActionCell.canMoveCellsLayerUp() {
                            ActionCell.moveCellsLayerUp()
                        }
                        
                        self.runActions()
                    } else {
                        self.stopRobot = true
                        let turn = SKAction.animateWithTextures(self.getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05)
                        self.runAction(turn)
                        self.lightClearButton()
                    }
                }
            })
        })
    }
    
    func lightClearButton() {
        let clearButton = SKSpriteNode(imageNamed: "buttonClearWithLight")
        clearButton.name = "clear"
        clearButton.position = GameButtonType.getPosition(.Clear)()
        clearButton.userInteractionEnabled = true
        clearButton.zPosition = 1001
        scene!.addChild(clearButton)
    }
    
    func performActions() {
        if !ActionCell.cells.isEmpty && isOnStart {
            isOnStart = false
            
            
            for var i = 0 ; i < ActionCell.cells.count ; i += 1 {
                if (ActionCell.cells[i].numberOfRepeats > 1) {
                    
                    let rect = ActionCell.cells[i].rect!
                    for _ in 0  ..< ActionCell.cells[i].numberOfRepeats  {
                        for cell in rect.repeatCells {
                            appendAction(cell)
                        }
                        /*
                        var index = i
                        while(true) {
                            if (ActionCell.cells[index].numberOfRepeats != ActionCell.cells[index-1].numberOfRepeats) {
                                break
                            }
                            else {
                                appendAction(ActionCell.cells[index])
                                index++
                            }
                            if (j == ActionCell.cells[i].numberOfRepeats - 1) {
                                i = index - 1
                            }
                            if (index == ActionCell.cells.count) {
                                break
                            }
                        }
                       */
                    }
                     i += rect.repeatCells.count - 1 
                }
                else {
                    appendAction(ActionCell.cells[i])
                }
            }
            
            ActionCell.moveCellsLayerToTop()
            var sequence = [SKAction.runBlock() { self.detail!.fixPosition() }]

            if isTurnedToFront {
                sequence.append(turnFromFront())
            }
            sequence.append(SKAction.runBlock() { self.runActions() })
            runAction(SKAction.sequence(sequence))
        }
    }

    func mistake() -> SKAction {
        //notification

        let animate = SKAction.animateWithTextures(getRobotAnimation("Mistake", direction: direction), timePerFrame: 0.06)
        let redRectangle = SKSpriteNode(imageNamed: "mistake")
        redRectangle.zPosition = 2000
        redRectangle.position = CGPoint(x: 1760.5, y: 920)
        redRectangle.alpha = 0
        let redRectangleFadeIn = SKAction.runBlock() {
            self.scene!.addChild(redRectangle)
            redRectangle.runAction(SKAction.fadeInWithDuration(0.15))
        }
        
        
        let redRectangleFadeOut = SKAction.runBlock() {
            redRectangle.runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.fadeOutWithDuration(2), SKAction.removeFromParent()]))
        }
        
        let sequence = SKAction.sequence([redRectangleFadeIn, animate, redRectangleFadeOut])
        
        return sequence
    }
    
    func move() -> SKAction {
        let nextTrackPosition = self.track!.getNextRobotTrackPosition(direction)
        let nextFloorPosition = self.track!.getFloorPositionAt(nextTrackPosition)
        let changeZPosition = SKAction.runBlock() {
            self.changeZPosition(nextFloorPosition)
        }
        
        if floorPosition() == track!.getFloorPositionAt(track!.getNextRobotTrackPosition(direction)) {
            let move = SKAction.moveByX(Block.BlockFaceSize.width * CGFloat(direction.rawValue), y: 0, duration: 1.6)
        
            let animate = SKAction.group([SKAction.animateWithTextures(getRobotAnimation("Move", direction: direction), timePerFrame: 0.04, resize: true, restore: false)])
            let repeatAnimation = SKAction.repeatAction(animate, count: 5)
        
            let moveAndAnimate = SKAction.group([changeZPosition, setNextTrackPosition(), move, repeatAnimation])
        
            track!.setNextRobotTrackPosition(direction)
        
            return moveAndAnimate
        } else {
            let move = SKAction.moveByX(Block.BlockFaceSize.width * CGFloat(direction.rawValue)/5, y: 0, duration: 0.32)
            
            let animate = SKAction.group([SKAction.animateWithTextures(getRobotAnimation("Move", direction: direction), timePerFrame: 0.04, resize: true, restore: false)])
            let repeatAnimation = SKAction.repeatAction(animate, count: 1)
            
            let moveAndAnimate = SKAction.group([move, repeatAnimation])
            
            let sequence = SKAction.sequence([moveAndAnimate, jump(true)])
            
            return sequence
        }
    }
    
    func catchVirus() -> SKAction {
        if (track!.virused) {
                let atlas = SKTextureAtlas(named: "CatchVirus")
                var textures : [SKTexture] = []
            for var i = 1; i < 5 ; i += 1 {
                textures.append(SKTexture(imageNamed: "CatchVirus_\(i)"))
            }
                let turn = SKAction.animateWithTextures(getRobotAnimation("TurnToFront", direction: self.direction), timePerFrame: 0.05, resize: true, restore: false)
                let open = SKAction.animateWithTextures(textures, timePerFrame: 0.075, resize: false, restore: false)
                let close = SKAction.animateWithTextures(textures.reverse(), timePerFrame: 0.075, resize: false, restore: false)
                let reverseTurn = SKAction.animateWithTextures(getRobotAnimation("TurnFromFront", direction: self.direction), timePerFrame: 0.05, resize: true, restore: false)
            
                return SKAction.sequence([turn , open , track!.fadeOutVirus() , close, reverseTurn])

        }
        else {
            return SKAction()
        }
    }
    
    func turn() -> SKAction {
        let sound = SKAction.runBlock() {
            AudioPlayer.sharedInstance.playSoundEffect("Reverse.mp3")
        }
        
        let animate = SKAction.animateWithTextures(
            getRobotAnimation("Turn", direction: direction), timePerFrame: 0.08, resize: true, restore: false)
        let changeAnimationDirection = SKAction.runBlock() {
            self.changeAnimationDirection()
        }
        direction.toggle()
        
        let action = SKAction.group([changeAnimationDirection, sound, animate])
        return action
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        AudioPlayer.sharedInstance.playSoundEffect("Sound_Tap.mp3")
        if isOnStart {
            if !isTurnedToFront {
                runAction(turnToFront())
                TouchesAnalytics.sharedInstance.appendTouch("RobotTurnToFrontTouch")
            } else {
                runAction(turnFromFront())
                TouchesAnalytics.sharedInstance.appendTouch("RobotTurnFromFrontTouch")
            }
        }
    }
    
    func turnToFront() -> SKAction {
        if (!self.hasActions()) {
        self.isTurnedToFront = true
        let block = SKAction.runBlock() {
            if (!self.track!.virused) {
                for button in self.actionButtons {
                    if (button.actionType != .Catch) {
                        self.addChild(button)
                        button.showButton()
                    }
                }
            }
            else {
                for button in self.actionButtons {
                    self.addChild(button)
                    button.showButton()
                }
            }
        
            let animate = SKAction.animateWithTextures(self.getRobotAnimation("TurnToFront", direction: .ToRight), timePerFrame: 0.05, resize: true, restore: false)
            self.runAction(animate)
        }
        
        return block
        }
        else {
            return SKAction()
        }
    }
    
    func turnFromFront(duration: NSTimeInterval = 0.05) -> SKAction {
        if (!self.hasActions()) {
        let animate = SKAction.animateWithTextures(getRobotAnimation("TurnFromFront", direction: .ToRight), timePerFrame: duration, resize: true, restore: false)

        let turnFromFront = SKAction.runBlock() {
            self.isTurnedToFront = false
        }
        
        var hideButtonActions: [SKAction] = []
        for button in actionButtons {
            hideButtonActions.append(SKAction.runBlock() {
                button.hideButton(duration * 2)
            })
        }
        
        let sequence = SKAction.sequence([SKAction.runBlock() { self.runningActions = true }, turnFromFront, SKAction.group(hideButtonActions), animate, SKAction.runBlock() { self.runningActions = false }])
        
        return sequence
        }
        else {
            return SKAction()
        }
    }
    
    private func changeZPosition(floorPosition: FloorPosition) {
        zPosition = CGFloat(floorPosition.rawValue + 101 )
    }
    
    func jump(afterStep: Bool) -> SKAction {
        let nextTrackPosition = track!.getNextRobotTrackPosition(direction)
        var currentPositionPoint = getCurrentPosition()
        let nextFloorPosition = track!.getFloorPositionAt(nextTrackPosition)
        
        if afterStep {
            let x = Int(currentPositionPoint.x) + Int(Block.BlockFaceSize.width * CGFloat(direction.rawValue)/5)
            currentPositionPoint.x = CGFloat(x)
        }
    
        let path = UIBezierPath()
        path.moveToPoint(currentPositionPoint)
        let endPoint = CGPoint(x: getNextPosition(direction).x , y: getNextPosition(direction).y + 60)
        var controlPoint: CGPoint

        if floorPosition() != track!.getFloorPositionAt(nextTrackPosition) {
            controlPoint = CGPoint(x: (getNextPosition(direction).x + currentPositionPoint.x)/2, y: max(getNextPosition(direction).y, currentPositionPoint.y) + Block.BlockFaceSize.height)
        } else {
            controlPoint = CGPoint(x: (getNextPosition(direction).x + currentPositionPoint.x)/2, y: max(getNextPosition(direction).y, currentPositionPoint.y) + Block.BlockFaceSize.height/2)
        }
        path.addQuadCurveToPoint(endPoint, controlPoint: controlPoint)
        
        let animateBegin = SKAction.animateWithTextures(getRobotAnimation("Jump", direction: direction), timePerFrame: 0.04, resize: true, restore: false)
        let moveByCurve = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: false, duration: 1)
        let animateEnd =  SKAction.group([SKAction.moveTo(self.getNextPosition(direction), duration: 0.2), animateBegin.reversedAction()])
        
        let sound = SKAction.runBlock() {
            AudioPlayer.sharedInstance.playSoundEffect("Jump.wav")
        }
        let changeZPosition = SKAction.runBlock() {
            self.changeZPosition(nextFloorPosition)
        }
        var moveAndChangezPos : SKAction
        
        if direction == .ToRight {
            moveAndChangezPos = SKAction.sequence([moveByCurve , changeZPosition])
        }
        else {
            if (trackPosition() != 0 && track!.getFloorPositionAt(trackPosition() + direction.rawValue).rawValue == track!.getFloorPositionAt(trackPosition()).rawValue + 1) {
                moveAndChangezPos = SKAction.sequence([changeZPosition , moveByCurve])
            }
            else {
                moveAndChangezPos = SKAction.sequence([moveByCurve , changeZPosition])

            }
        }
        
        let sequence = SKAction.sequence([setNextTrackPosition(), setNextFloorPosition(nextFloorPosition), animateBegin, sound ,moveAndChangezPos , animateEnd])
        
        track!.setNextRobotTrackPosition(direction)
        
        return sequence
    }
    
    func push() -> SKAction {
        let sequence = SKAction.sequence([push_FirstPart(), track!.moveBlock(direction), push_SecondPart()])
        return sequence
    }
    
    func push_FirstPart() -> SKAction {
        let animate = SKAction.animateWithTextures(getRobotAnimation("Push_FirstPart", direction: direction), timePerFrame: 0.08, resize: true, restore: false)
        let sound = SKAction.runBlock() {
            AudioPlayer.sharedInstance.playSoundEffect("CubePush.mp3")
        }
        let action = SKAction.group([animate, sound])
        return action
    }
    
    func push_SecondPart() -> SKAction {
        let animate = SKAction.animateWithTextures(getRobotAnimation("Push_SecondPart", direction: direction), timePerFrame: 0.08, resize: true, restore: false)
        
        return animate
    }
    
    func fadeOutInTheDoor() -> SKAction {
        var str : String!
        if (direction == .ToRight) {
            str = "ToRight"
        }
        else {
            str = "ToLeft"
        }
        let firstAtlas = SKTextureAtlas(named: "FadeOutInDoor_\(str)")
        var textures : [SKTexture] = []
        for i in 0  ..< firstAtlas.textureNames.count  {
            textures.append(SKTexture(imageNamed: "RobotFOD_\(str)_\(String(i + 1))"))
        }
        let turnAnimate = SKAction.animateWithTextures(textures, timePerFrame: 0.06, resize: false , restore: false)
        let secondAtlas = SKTextureAtlas(named: "WalkingAway")
        var secondTextures : [SKTexture] = []
        for i in 0  ..< secondAtlas.textureNames.count {
            secondTextures.append(SKTexture(imageNamed: "Robot_WalkAway_\(String(i + 1))"))
        }
        let walkAway = SKAction.animateWithTextures(secondTextures, timePerFrame: 0.06, resize: true , restore: false)
        let fadeOut = SKAction.fadeOutWithDuration(0.3)
        let group = SKAction.group([walkAway , fadeOut])
        let sequence = SKAction.sequence([turnAnimate , group ])
        return sequence
    }
    
    func moveToStart() {
        currentTrackPosition = track!.getRobotStartPosition()
        currentFloorPosition = track!.getFloorPositionAt(currentTrackPosition)
        position = getCurrentPosition()
        changeZPosition(floorPosition())
    }
    
    func getStartPosition() -> Int {
        return track!.getRobotStartPosition()
    }
    
    func changeAnimationDirection() {
        if animationDirection == .ToRight {
            animationDirection = .ToLeft
        } else {
            animationDirection = .ToRight
        }
    }
    
    func isOnDetailPosition() -> Bool {
        return track!.robotIsOnDetailPosition()
    }
    
    private func trackPosition() -> Int {
        return track!.getCurrentRobotPosition()
    }

    private func getCurrentFloorPosition() -> FloorPosition {
        return track!.getFloorPositionAt(currentTrackPosition)
    }
    
    private func floorPosition() -> FloorPosition {
        return track!.getFloorPositionAt(trackPosition())
    }
    
    private func setNextTrackPosition() -> SKAction {
        return SKAction.runBlock() {
            self.currentTrackPosition += self.animationDirection.rawValue
        }
    }

    private func setNextFloorPosition(floorPosition: FloorPosition) -> SKAction {
        return SKAction.runBlock() {
            self.currentFloorPosition = floorPosition
        }
    }

    func getPosition(trackPosition: Int, floorPosition: FloorPosition) -> CGPoint {
        let X = FirstBlockPosition.x + CGFloat(trackPosition - 1) * Block.BlockFaceSize.width
        let dY = (floorPosition.rawValue - 1) * 203
        let Y: CGFloat = CGFloat(734 + dY)
        return CGPoint(x: X, y: Y)
    }
    
    func getCurrentPosition() -> CGPoint {
        return getPosition(trackPosition(), floorPosition: floorPosition())
    }
    
    func getNextPosition(direction: Direction) -> CGPoint {
        return getPosition(trackPosition() + direction.rawValue, floorPosition: track!.getFloorPositionAt(trackPosition() + direction.rawValue))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRobotAnimation(actionType: String, direction: Direction) -> [SKTexture] {
        var textures: [SKTexture] = []
        var directionString: String = ""
        
        if direction == .ToRight && actionType != "mistake" {
            directionString = "_ToRight"
        } else {
            directionString = "_ToLeft"
        }
        
        let atlasName = "Animation_\(actionType)\(directionString)"
        let atlas = SKTextureAtlas(named: atlasName)
        
        for var i = 1; i <= atlas.textureNames.count; i += 1 {
            textures.append(atlas.textureNamed("\(atlasName)_\(i)"))
        }
        
        return textures
    }
}