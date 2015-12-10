//
//  RobotTrack.swift
//  Codebusters_sample
//
//  Created by Alexander on 11.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

class RobotTrack {
    private var track: [RobotStanding] = []
    private var currentRobotPosition = 0
    private var startRobotPosition = 0
    var detailPosition = 0
    var detailFloorPosition = FloorPosition.first
    
    init() {
        getCurrentLevelTrackInfo()
    }
    
    private func getCurrentLevelTrackInfo() {
        let levelData = GameProgress.sharedInstance.getCurrentLevelData()
        
        if let pattern = levelData["blocksPattern"] as? [Int] {
            initTrackFromPattern(pattern)
        }
        
        if let robotPosition = levelData["robotPosition"] as? Int {
            currentRobotPosition = robotPosition
            startRobotPosition = robotPosition
        }
        
        if let detailPosition = levelData["detailPosition"] as? Int {
            self.detailPosition = detailPosition
        }
        
        if let detailFloorPositionInt = levelData["detailFloorPosition"] as? Int {
            if let detailFloorPosition = FloorPosition(rawValue: detailFloorPositionInt) {
                self.detailFloorPosition = detailFloorPosition
            }
        }
    }
    
    func trackLength(scale: CGFloat) -> CGFloat {
        return CGFloat(track.count) * Constants.BlockFace_Size.width * scale
    }
    
    func deleteBlocks() {
        for robotStanding in track {
            robotStanding.deleteBlocks()
        }
        
        track.removeAll(keepCapacity: false)
    }
    
    func initTrackFromPattern(pattern: [Int]) {
        track.append(RobotStanding(trackPosition: track.count, floorPosition: .ground))
        for var i = 0; i < pattern.count; i++ {
            if let floor = FloorPosition(rawValue: pattern[i]) {
                track.append(RobotStanding(trackPosition: i + 1, floorPosition: floor))
            }
        }
    }

    func canPerformActionWithDirection(action: ActionType, direction: Direction) -> Bool {
        switch action {
        case .move:
            if (getNextRobotTrackPosition(direction) < 0 || getNextRobotTrackPosition(direction) >= track.count) {
                return false
            }
            else {
            return ((track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue) && (track[getNextRobotTrackPosition(direction)].getFloorPosition() != .ground))
            }
        case .jump:
            if (getNextRobotTrackPosition(direction) < 0 || getNextRobotTrackPosition(direction) >= track.count) {
                return false
            }
            else {
             return track[currentRobotPosition].getFloorPosition() != .ground && track[getNextRobotTrackPosition(direction)].getFloorPosition() != .ground
            }
        case .push:
            if currentRobotPosition + 2 * direction.rawValue < 0 {
                return false
            }
            
            if currentRobotPosition + 2 * direction.rawValue >= track.count {
                track.append(RobotStanding(trackPosition: track.count, floorPosition: .ground))
            }
            
            if detailPosition == currentRobotPosition + 2 * direction.rawValue && detailFloorPosition == track[currentRobotPosition + 2 * direction.rawValue].getFloorPosition() {
                return false
            }
            
            return track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue || (track[getNextRobotTrackPosition(direction)].getFloorPosition() != track[currentRobotPosition + 2 * direction.rawValue].getFloorPosition() && track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue == track[currentRobotPosition].getFloorPosition().rawValue + 1)
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