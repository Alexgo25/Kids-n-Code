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
    private var currentRobotPosition: Int
    private let startRobotPosition: Int
    private let detailPosition: Int
    
    init(pattern: [FloorPosition], robotPosition: Int, detailPosition: Int) {
        startRobotPosition = robotPosition
        self.detailPosition = detailPosition
        currentRobotPosition = robotPosition
        
        initTrackFromPattern(pattern)
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
    
    func initTrackFromPattern(pattern: [FloorPosition]) {
        track.append(RobotStanding(trackPosition: track.count, floorPosition: .ground))
        for var i = 1; i <= pattern.count; i++ {
            track.append(RobotStanding(trackPosition: i, floorPosition: pattern[i - 1]))
        }
        track.append(RobotStanding(trackPosition: track.count, floorPosition: .ground))
    }
    
    func canPerformActionWithDirection(action: ActionType, direction: Direction) -> Bool {
        switch action {
        case .move:
            return ((track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue) && (track[getNextRobotTrackPosition(direction)].getFloorPosition() != .ground))
        case .jump:
            return track[currentRobotPosition].getFloorPosition() != .ground && track[getNextRobotTrackPosition(direction)].getFloorPosition() != .ground
        case .push:
            return track[currentRobotPosition].getFloorPosition().rawValue >= track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue || (track[getNextRobotTrackPosition(direction)].getFloorPosition() != track[currentRobotPosition + 2 * direction.rawValue].getFloorPosition() && track[getNextRobotTrackPosition(direction)].getFloorPosition().rawValue == track[currentRobotPosition].getFloorPosition().rawValue + 1)
        default:
            return true
        }
    }
    
    func resetRobotPosition() {
        currentRobotPosition = startRobotPosition
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



    
    
    
