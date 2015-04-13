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
    
    func canPerformActionWithDirection(action : ActionType , direction : Direction) -> Bool {
        switch action {
        case .moveForward:
            return track[currentRobotPosition].getFloorPosition().rawValue == track[getNextStanding(direction)].getFloorPosition().rawValue
        case .jump:
            return track[currentRobotPosition].getFloorPosition() != .ground
        case .push:
            return track[currentRobotPosition].getFloorPosition().rawValue < track[getNextStanding(direction)].getFloorPosition().rawValue
        default:
            return true
        }
    }
    
    func getNextStanding(direction: Direction) -> Int {
        return currentRobotPosition + direction.rawValue
    }
    
    init (robotPosition: Int) {
        currentRobotPosition = robotPosition
    }
    
    func append(robotStanding: RobotStanding) {
        track.append(robotStanding)
    }
    
    func setNextStanding(direction: Direction) {
        currentRobotPosition = getNextStanding(direction)
    }
}