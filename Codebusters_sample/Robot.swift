//
//  Robot.swift
//  Codebusters_sample
//
//  Created by Alexander on 01.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction: Int {
    case ToRight = 1,
    ToLeft = -1
}

class Robot: SKSpriteNode, SKPhysicsContactDelegate {
    
    private var actions: [SKAction] = []
    private var currentActionIndex = 0

    private var direction: Direction = .ToRight // рассчитывается заранее
    private var animationDirection: Direction = .ToRight // рассчитывается во время движения
    private var turnedToFront = false
    private var stopRobot = false
    private var robotTookDetail = false
    private var debugging = false
    private var runningActions = false
    
    var track: RobotTrack
    
    private let actionButtons = [ActionButton(type: .move), ActionButton(type: .turn), ActionButton(type: .push), ActionButton(type: .jump)]
    var isOnStart = true
    
    init(track: RobotTrack) {
        let texture = SKTexture(imageNamed: "robot")
        self.track = track
        super.init(texture: texture, color: UIColor(), size: texture.size())
        zPosition = 101
        moveToStart()
        actions = []
        userInteractionEnabled = true

        physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width - 50, height: size.height - 70))
        physicsBody!.categoryBitMask = PhysicsCategory.Robot
        physicsBody!.contactTestBitMask = PhysicsCategory.Detail
        physicsBody!.collisionBitMask = 0
        setScale(0.8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isRunningActions() -> Bool {
        return debugging || runningActions
    }
    
    func currentAction() -> Int {
        return currentActionIndex
    }
    
    func canPerformAction(actionType: ActionType) -> Bool {
        return track.canPerformActionWithDirection(actionType, direction: direction)
    }
    
    func takeDetail() {
        stopRobot = true
        robotTookDetail = true
    }
    
    func appendAction(actionType: ActionType) -> Bool {
        if canPerformAction(actionType) {
            let highlightBeginAction = ActionCell.cells[actions.count].highlightBegin()
            let highlightEndAction = ActionCell.cells[actions.count].highlightEnd()
            var action: SKAction
            switch actionType {
            case .move:
                action = move()
            case .turn:
                action = turn()
            case .jump:
                action = jump(false)
            case .push:
                action = push()
            default:
                return false
            }
            let sequence = SKAction.sequence([SKAction.runBlock() { self.runningActions = true },  highlightBeginAction, action, highlightEndAction, SKAction.runBlock() { self.runningActions = false }])
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
        actions.removeAll(keepCapacity: false)
        direction = .ToRight
        animationDirection = .ToRight
        removeAllActions()
        if !turnedToFront {
            texture = SKTexture(imageNamed: "robot")
        }
        moveToStart()
        track.resetRobotPosition()
        currentActionIndex = 0
        robotTookDetail = false
        debugging = false
        runningActions = false
    }

    func startDebugging() {
        if !ActionCell.cells.isEmpty {
            debugging = true
            
            if isOnStart {
                isOnStart = false
                
                for cell in ActionCell.cells {
                    if appendAction(cell.getActionType()) {
                        break
                    }
                }
                
                ActionCell.moveCellsLayerToTop()
                
                if turnedToFront {
                    runAction(self.turnFromFront(), completion: { self.debug() } )
                } else {
                    debug()
                }
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
                        if self.stopRobot {
                            let turn = SKAction.animateWithTextures(getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05, resize: true, restore: false)
                            
                            if self.robotTookDetail {
                                self.runAction(turn)
                            } else {
                                let sequence = SKAction.sequence([turn, self.mistake()])
                                self.runAction(sequence)
                            }
                        } else {
                            if self.currentActionIndex < self.actions.count - 1 {
                                self.currentActionIndex++
                                if self.currentActionIndex > 5 && self.currentActionIndex + 5 < ActionCell.cellsCount() && ActionCell.canMoveCellsLayerUp() {
                                    ActionCell.moveCellsLayerUp()
                                }
                            } else {
                                self.stopRobot = true
                                let turn = SKAction.animateWithTextures(getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05)
                                self.runAction(turn)
                            }
                        }
                    })
                })
            }
            debugging = false
        }
    }
    
    func runActions() {
        runAction(actions[currentActionIndex], completion: {
            self.runAction(SKAction.runBlock() {
                if self.stopRobot {
                    let turn = SKAction.animateWithTextures(getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05, resize: true, restore: false)
                    if self.robotTookDetail {
                        self.runAction(turn)
                    } else {
                        let sequence = SKAction.sequence([turn, self.mistake()])
                        self.runAction(sequence)
                    }
                    
                    return
                } else {
                    if self.currentActionIndex < self.actions.count - 1 {
                        self.currentActionIndex++

                        if self.currentActionIndex > 5 && self.currentActionIndex + 5 < ActionCell.cellsCount() && ActionCell.canMoveCellsLayerUp() {
                            ActionCell.moveCellsLayerUp()
                        }
                        
                        self.runActions()
                    } else {
                        let turn = SKAction.animateWithTextures(getRobotAnimation("TurnToFront", direction: self.animationDirection), timePerFrame: 0.05)
                        self.runAction(turn)
                    }
                }
            })
        })
    }
    
    func performActions() {
        if !ActionCell.cells.isEmpty && isOnStart {
            isOnStart = false
            
            for cell in ActionCell.cells {
                if appendAction(cell.getActionType()) {
                    break
                }
            }
            
            ActionCell.moveCellsLayerToTop()
            
            if turnedToFront {
                runAction(self.turnFromFront(), completion: { self.runActions() } )
                return
            } else {
                runActions()
            }
        } 
    }
    
    func mistake() -> SKAction {
        let animate = SKAction.animateWithTextures(getRobotAnimation("Mistake", direction: direction), timePerFrame: 0.06)

        return animate
    }
    
    func move() -> SKAction {
        if floorPosition() == track.getFloorPositionAt(track.getNextRobotTrackPosition(direction)) {
            let move = SKAction.moveByX(Constants.BlockFace_Size.width * CGFloat(direction.rawValue), y: 0, duration: 1.6)
        
            let animate = SKAction.group([SKAction.animateWithTextures(getRobotAnimation("Move", direction: direction), timePerFrame: 0.04, resize: true, restore: false)])
            let repeatAnimation = SKAction.repeatAction(animate, count: 5)
        
            let moveAndAnimate = SKAction.group([move, repeatAnimation])
        
            track.setNextRobotTrackPosition(direction)
        
            return moveAndAnimate
        } else {
            let move = SKAction.moveByX(Constants.BlockFace_Size.width * CGFloat(direction.rawValue)/5, y: 0, duration: 0.32)
            
            let animate = SKAction.group([SKAction.animateWithTextures(getRobotAnimation("Move", direction: direction), timePerFrame: 0.04, resize: true, restore: false)])
            let repeatAnimation = SKAction.repeatAction(animate, count: 1)
            
            let moveAndAnimate = SKAction.group([move, repeatAnimation])
            let sequence = SKAction.sequence([moveAndAnimate, jump(true)])
            
            return sequence
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
        changeDirection()
        
        let action = SKAction.group([changeAnimationDirection, sound, animate])
        return action
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !turnedToFront && isOnStart {
            runAction(turnToFront())
        }
    }
    
    func turnToFront() -> SKAction {
        let block = SKAction.runBlock() {
            for button in self.actionButtons {
                self.addChild(button)
                button.showButton()
            }
        
            let animate = SKAction.animateWithTextures(getRobotAnimation("TurnToFront", direction: .ToRight), timePerFrame: 0.05, resize: true, restore: false)
            self.runAction(animate)
            self.turnedToFront = true
        }
        
        return block
    }
    
    func turnFromFront() -> SKAction {
        let animate = SKAction.animateWithTextures(getRobotAnimation("TurnFromFront", direction: .ToRight), timePerFrame: 0.05, resize: true, restore: false)

        let turnFromFront = SKAction.runBlock() {
            self.turnedToFront = false
        }
        
        var hideButtonActions: [SKAction] = []
        for button in actionButtons {
            hideButtonActions.append(SKAction.runBlock() {
                button.hideButton()
            })
        }
        
        let sequence = SKAction.sequence([SKAction.runBlock() { self.runningActions = true }, turnFromFront, SKAction.group(hideButtonActions), animate, SKAction.runBlock() { self.runningActions = false }])
        
        return sequence
    }
    
    func jump(afterStep: Bool) -> SKAction {
        let nextTrackPosition = self.track.getNextRobotTrackPosition(direction)
        var currentPositionPoint = getCurrentPositionPoint()
      
        if afterStep {
            let x = Int(currentPositionPoint.x) + Int(Constants.BlockFace_Size.width * CGFloat(direction.rawValue)/5)
            currentPositionPoint.x = CGFloat(x)
        }
    
        let path = UIBezierPath()
        path.moveToPoint(currentPositionPoint)
        let endPoint = CGPoint(x: getNextPositionPoint(direction).x , y: getNextPositionPoint(direction).y + 45)
        var controlPoint: CGPoint

        if floorPosition() != track.getFloorPositionAt(nextTrackPosition) {
            controlPoint = CGPoint(x: (getNextPositionPoint(direction).x + currentPositionPoint.x)/2, y: max(getNextPositionPoint(direction).y, currentPositionPoint.y) + UIImage(named: "block")!.size.height )
        } else {
            controlPoint = CGPoint(x: (getNextPositionPoint(direction).x + currentPositionPoint.x)/2, y: max(getNextPositionPoint(direction).y, currentPositionPoint.y) + UIImage(named: "block")!.size.height/2 )
        }
        path.addQuadCurveToPoint(endPoint, controlPoint: controlPoint)
        
        let animateBegin = SKAction.animateWithTextures(getRobotAnimation("Jump", direction: direction), timePerFrame: 0.04, resize: true, restore: false)
        let moveByCurve = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: false, duration: 1)
        let animateEnd =  SKAction.group([SKAction.moveTo(self.getNextPositionPoint(direction), duration: 0.2), animateBegin.reversedAction()])
        
        let sound = SKAction.runBlock() {
            AudioPlayer.sharedInstance.playSoundEffect("Jump.wav")
        }
        
        let sequence = SKAction.sequence([animateBegin, sound, moveByCurve, animateEnd])
        
        track.setNextRobotTrackPosition(direction)
        
        return sequence
    }
    
    func push() -> SKAction {
        let sequence = SKAction.sequence([push_FirstPart(), track.moveBlock(direction), push_SecondPart()])
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
    
    func moveToStart() {
        stopRobot = false
        //turnedToFront = false
        isOnStart = true
        position = getCGPointOfPosition(track.getRobotStartPosition(), floorPosition: track.getFloorPositionAt(track.getRobotStartPosition()))
    }
    
    func getStartPosition() -> Int {
        return track.getRobotStartPosition()
    }
    
    func getCurrentPositionPoint() -> CGPoint {
        return getCGPointOfPosition(trackPosition(), floorPosition: floorPosition())
    }
    
    func getNextPositionPoint(direction: Direction) -> CGPoint {
        return getCGPointOfPosition(trackPosition() + direction.rawValue, floorPosition: track.getFloorPositionAt(trackPosition() + direction.rawValue))
    }
    
    func getDirection() -> Direction {
        return direction
    }
    
    func changeDirection() {
        if direction == .ToRight {
            direction = .ToLeft
        } else {
            direction = .ToRight
        }
    }
    
    func changeAnimationDirection() {
        if animationDirection == .ToRight {
            animationDirection = .ToLeft
        } else {
            animationDirection = .ToRight
        }
    }
    
    func isTurnedToFront() -> Bool {
        return turnedToFront
    }
    
    func isOnDetailPosition() -> Bool {
        return track.robotIsOnDetailPosition()
    }
    
    private func trackPosition() -> Int {
        return track.getCurrentRobotPosition()
    }
    
    private func floorPosition() -> FloorPosition {
        return track.getFloorPositionAt(trackPosition())
    }
}