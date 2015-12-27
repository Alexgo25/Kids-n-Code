//
//  LevelPackData.swift
//  Kids'n'Code
//
//  Created by Владислав Кутейников on 22.12.15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation

struct LevelPackData {
    var detailType: DetailType {
        didSet {
            dictionary.updateValue(detailType.rawValue, forKey: "detailType")
        }
    }
    
    var cellState: DetailCellState {
        didSet {
            dictionary.updateValue(cellState.rawValue, forKey: "cellState")
        }
    }
    
    var levels: [[String: AnyObject]] {
        didSet {
            dictionary.updateValue(levels, forKey: "levels")
        }
    }
    
    var dictionary: [String: AnyObject]
    
    init(levelPackData: [String: AnyObject]) {
        dictionary = levelPackData
        let detailTypeString = levelPackData["detailType"] as! String
        
        let detailCellStateString = levelPackData["cellState"] as! String
        
        guard let detailType = DetailType(rawValue: detailTypeString), let detailCellState = DetailCellState(rawValue: detailCellStateString) else { fatalError() }
            self.detailType = detailType
            cellState = detailCellState
        
        levels = levelPackData["levels"] as! [[String: AnyObject]]
    }
}