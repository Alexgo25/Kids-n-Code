//
//  VirusedLevelsGameProgress.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation


class VirusedLevelsGameProgress {
    
    var levelsInfo : [LevelConfiguration] = []
    
    init() {
        
    }
    
    func getLevelConfiguration(levelNumber : Int) -> LevelConfiguration {
        return LevelConfiguration(info: getLevelsData()[levelNumber] as! [String : AnyObject])
    }
    
    func getLevelsData() -> NSArray {
        let path = getLevelsDataPath()
        let config = NSArray(contentsOfFile: path)!
        return config
    }
    
    func getLevelsDataPath() -> String {
        //let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let bundlePath = NSBundle.mainBundle().pathForResource("Levels_2", ofType: "plist")!
        //let fileURL = documentsURL.URLByAppendingPathComponent("Levels_2.plist")
        return bundlePath
    }
}
