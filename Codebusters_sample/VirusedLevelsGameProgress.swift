//
//  VirusedLevelsGameProgress.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation


class VirusedLevelsGameProgress {
    
    static var levelsInfo : [LevelConfiguration] = []
    var currentLevel = 0
    
    init() {
        let arr = getLevelsData()
        for element in arr {
            let levelInfo = LevelConfiguration(info: element as! [String : AnyObject])
            VirusedLevelsGameProgress.levelsInfo.append(levelInfo)
        }
    }
    
    func getLevelConfiguration(levelNumber : Int) -> LevelConfiguration {
        return LevelConfiguration(info: getLevelsData()[levelNumber] as! [String : AnyObject])
    }
    
    func getLevelsData() -> NSArray {
        let path = getLevelsDataPath()
        let config = NSArray(contentsOfFile: path)!
        return config
    }
    
    func writeResultsOfCurrentLevel(result: Int) {
        let path = getLevelsDataPath()
        let levels = NSMutableArray(contentsOfFile: path)
        if (currentLevel < 16) {
            let currentLevelData = levels![currentLevel] as! NSMutableDictionary
            if (currentLevelData["result"] as! Int > result) {
                currentLevelData["result"] = result
            }
            if (currentLevel != 15) {
                let nextLevelData = levels![currentLevel + 1] as! NSMutableDictionary
                if (!(nextLevelData["isOpened"] as! Bool)) {
                    nextLevelData["isOpened"] = true
                }
            }
            
        }
        
        
    }
    
    func getLevelsDataPath() -> String {
        //let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let bundlePath = NSBundle.mainBundle().pathForResource("Levels_2", ofType: "plist")!
        //let fileURL = documentsURL.URLByAppendingPathComponent("Levels_2.plist")
        return bundlePath
    }
    
    func setNextLevel() {
        if (currentLevel < 15) {
            currentLevel++
        }
    }
}
