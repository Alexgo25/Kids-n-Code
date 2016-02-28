//
//  LevelConfiguration.swift
//  Kids'n'Code
//
//  Created by Владислав Кутейников on 23.12.15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation

struct LevelConfiguration {
    private let configurationDictionary: [String: AnyObject]
    
    var isOpened: Bool {
        return configurationDictionary["isOpened"] as! Bool
    }
    
    var blocksPattern: [FloorPosition]
    
    var robotPosition: Int {
        return configurationDictionary["robotPosition"] as! Int
    }
    
    var detailPosition: Int {
        return configurationDictionary["detailPosition"] as! Int
    }
    
    var virusPosition: Int {
        if (configurationDictionary["virusPosition"] == nil) {
            return -1
        }
        else {
            return configurationDictionary["virusPosition"] as! Int
        }
    }
    
    var detailFloorPosition: FloorPosition {
        let floorPositionInt = configurationDictionary["detailFloorPosition"] as! Int
        return FloorPosition(rawValue: floorPositionInt)!
    }
    
    var tutorial: Int? {
        return configurationDictionary["tutorial"] as! Int?
    }
    
    var currentResult: Int {
        return configurationDictionary["result"] as! Int
    }
    
    var goodResult: Int {
        return configurationDictionary["result_1"] as! Int
    }
    
    var badResult: Int {
        return configurationDictionary["result_2"] as! Int
    }
    
    var detailType: DetailType {
        if let detailTypeString = configurationDictionary["detailType"] as? String {
            return DetailType(rawValue: detailTypeString)!
        } else {
            return .Crystall
        }
    }
    
    init(info: [String: AnyObject]) {
        configurationDictionary = info
        
        let blocks = configurationDictionary["blocksPattern"] as! [Int]
        
        blocksPattern = []
        for block in blocks {
            blocksPattern.append(FloorPosition(rawValue: block)!)
        }
    }
}