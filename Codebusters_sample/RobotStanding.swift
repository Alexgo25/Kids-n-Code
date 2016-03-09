//
//  RobotStanding.swift
//  Codebusters_sample
//
//  Created by Alexander on 11.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

enum FloorPosition: Int {
    case Ground = 0,
    First = 1,
    Second = 2,
    Third = 3,
    Fourth = 4,
    Fifth = 5
}

class RobotStanding {
    
    private var floorPosition: FloorPosition
    private var blocks: [Block] = []
    private var trackPosition: Int
    
    init (trackPosition: Int, floorPosition: FloorPosition) {
        self.floorPosition = floorPosition
        self.trackPosition = trackPosition
        for var i = 1; i <= floorPosition.rawValue; i++ {
            if let floor = FloorPosition(rawValue: i) {
                blocks.append(Block(trackPosition: trackPosition, floorPosition: floor))
            }
        }
    }
    
    func getFloorPosition() -> FloorPosition {
        return floorPosition
    }
    
    func appendBlock(block: Block) {
        blocks.append(block)
        if let floor = FloorPosition(rawValue: blocks.count) {
            floorPosition = floor
        }
    }
    
    func removeLastBlock() {
        blocks.removeLast()
        if let floor = FloorPosition(rawValue: blocks.count) {
            floorPosition = floor
        }
    }
    
    func deleteBlocks() {
        for block in blocks {
            block.removeFromParent()
        }
        
        blocks.removeAll(keepCapacity: false)
    }
    
    func moveUpperBlock(direction: Direction, floorPosition: FloorPosition) -> SKAction {
        let action = blocks.last!.moveToNextPosition(direction, floorPosition: floorPosition)
        return action
    }
    
    func getUpperBlock() -> Block {
        return blocks.last!
    }
    
    func getBlockAt(floorPosition: Int) -> Block {
        return blocks[floorPosition]
    }
}
