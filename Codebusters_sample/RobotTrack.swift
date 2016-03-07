//
//  RobotTrack.swift
//  Codebusters_sample
//
//  Created by Alexander on 11.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

class RobotTrack {
    private var track: [RobotStanding] = []
    private var currentRobotPosition = 0
    private var startRobotPosition = 0
    var virus : LevelVirus?
    var secondVirus : LevelVirus?
    var thirdVirus : LevelVirus?
    var viruses : [LevelVirus?] = []
    var detailPosition = 0
    var detailFloorPosition = FloorPosition.First
    var virused = false
    
    init(levelInfo: LevelConfiguration) {
        getCurrentLevelTrackInfo(levelInfo)
    }

    private func getCurrentLevelTrackInfo(levelInfo: LevelConfiguration) {
        let pattern = levelInfo.blocksPattern
        initTrackFromPattern(pattern)
        startRobotPosition = levelInfo.robotPosition
        currentRobotPosition = startRobotPosition
        detailPosition = levelInfo.detailPosition
        detailFloorPosition = levelInfo.detailFloorPosition
        
    }
    
    func trackLength(scale: CGFloat) -> CGFloat {
        return (CGFloat(track.count) + 1) * Block.BlockFaceSize.width * scale
    }
    
    func deleteBlocks() {
        for robotStanding in track {
            robotStanding.deleteBlocks()
        }
        
        track.removeAll(keepCapacity: false)
    }
    
    func initTrackFromPattern(pattern: [FloorPosition]) {
        track.append(RobotStanding(trackPosition: track.count, floorPosition: .Ground))
        for var i = 0; i < pattern.count; i++ {
            track.append(RobotStanding(trackPosition: i + 1, floorPosition: pattern[i]))
        }
    }
    
    func canPerformActionWithDirection(action: ActionType, direction: Direction) -> Bool {
        switch action {
        case .Move:
            if currentRobotPosition + direction.rawValue < 0 || currentRobotPosition + direction.rawValue >= track.count {
                return false
            }
            
            return ((track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue) && (track[getNextRobotTrackPosition(direction)].getFloorPosition() != .Ground))
        case .Jump:
            if currentRobotPosition + direction.rawValue < 0 || currentRobotPosition + direction.rawValue >= track.count {
                return false
            }
            
            return track[currentRobotPosition].getFloorPosition() != .Ground && track[getNextRobotTrackPosition(direction)].getFloorPosition() != .Ground
        case .Push:
            if currentRobotPosition + 2 * direction.rawValue < 0 {
                return false
            }
            
            if currentRobotPosition + 2 * direction.rawValue >= track.count {
                track.append(RobotStanding(trackPosition: track.count, floorPosition: .Ground))
            }
            
            if detailPosition == currentRobotPosition + 2 * direction.rawValue && detailFloorPosition == track[currentRobotPosition + 2 * direction.rawValue].getFloorPosition() {
                return false
            }
            
            return track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue || (track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue > track[currentRobotPosition + 2 * direction.rawValue].getFloorPosition().rawValue && track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue > track[currentRobotPosition].getFloorPosition().rawValue)
        case .Catch:
            return true
        default:
            return true
        }
    }
    
    func getBlocksPattern() -> [FloorPosition] {
        var array: [FloorPosition] = []
        
        for block in track {
            array.append(block.getFloorPosition())
        }
        
        return array
    }
    
    func robotIsOnDetailPosition() -> Bool {
        return currentRobotPosition == detailPosition
    }
    
    func getRobotStartPosition() -> Int {
        return startRobotPosition
    }
    
    func getNextRobotTrackPosition(direction: Direction) -> Int {
        return currentRobotPosition + direction.rawValue
    }
    
    func append(robotStanding: RobotStanding) {
        track.insert(robotStanding, atIndex: track.count - 1)
    }
    
    func setNextRobotTrackPosition(direction: Direction) {
        currentRobotPosition = getNextRobotTrackPosition(direction)
    }
    
    func getCurrentRobotPosition() -> Int {
        return currentRobotPosition
    }
    
    func getFloorPositionAt(position: Int) -> FloorPosition {
        return track[position].getFloorPosition()
    }
    
    func fadeOutVirus() -> SKAction {
        if (currentRobotPosition == virus!.trackPosition) {
            
            return SKAction.group([virus!.fadeOut() , SKAction.runBlock({
                self.virused = false
            })])
        }
        else {
            return SKAction()
        }
    }
    
    
    func moveBlock(direction: Direction) -> SKAction {
        if track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue {
            return SKAction()
        }
        
        
        
        track[getNextRobotTrackPosition(direction) + direction.rawValue].appendBlock(track[getNextRobotTrackPosition(direction)].getUpperBlock())
        track[getNextRobotTrackPosition(direction)].removeLastBlock()
        let action = track[currentRobotPosition + 2 * direction.rawValue].moveUpperBlock(direction, floorPosition: track[getNextRobotTrackPosition(direction) + direction.rawValue].getFloorPosition())
        return action
    }
    
    func getBlockAt(trackPosition: Int, floorPosition: Int) -> Block {
        return track[trackPosition].getBlockAt(floorPosition)
    }
}