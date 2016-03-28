//
//  VirusedLevelsGameProgress.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation


public class VirusedLevelsGameProgress {
    
    var virusedLevelsInfo : [[String : AnyObject]] = [] {
        didSet {
            updatePlistFile()
        }
    }
    var currentLevel = 0
    
    init() {
        writePListToDevice()
        updateData()
    }
    
    
    
    func getLevelConfiguration(levelNumber : Int) -> LevelConfiguration {
        return LevelConfiguration(info: getLevelsData()[levelNumber] as! [String : AnyObject])
    }
    
    func getLevelsData() -> NSArray {
        let path = getLevelsDataPath()
        let config = NSArray(contentsOfFile: path)!
        return config
    }
    
    func updateData() {
        let arr = getLevelsData() as! [[String : AnyObject]]
        for element in arr {
            virusedLevelsInfo.append(element)
        }
    }
    
    func writePListToDevice() {
        let path = getLevelsDataPath()
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            if let bundle = NSBundle.mainBundle().pathForResource("Levels_2", ofType: "plist") {
                do {
                    try fileManager.copyItemAtPath(bundle, toPath: path)
                } catch _ {
                    print("mh")
                }
            }
        } /*else {
            if let _ = NSMutableArray(contentsOfFile: path) {
                
                do {
                    try fileManager.removeItemAtPath(path)
                }
                catch _ {
                    print("123")
                }
                writePListToDevice()
            }
        }*/

    }
    
    func getLevelsDataPath() -> String {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("Levels_2.plist")
        return fileURL.path!
    }
    
    func setNextLevel() {
        if (currentLevel < 15) {
            currentLevel += 1
        }
    }
    
    func openNextLevel() {
        let count = virusedLevelsInfo.count
        
        guard virusedLevelsInfo[currentLevel]["result"] as! Int > 0 else {
            return
        }
        
        if currentLevel + 1 < count {
            virusedLevelsInfo[currentLevel + 1].updateValue(true, forKey: kIsOpenedKey)
        }
        
    }
    
    func writeResultOfCurrentLevel(result : Int) {
        var data = self.virusedLevelsInfo
        let currentResult =  data[currentLevel]["result"] as! Int
        if (result < currentResult || currentResult == 0) {
            data[currentLevel].updateValue(result, forKey: "result")
            self.virusedLevelsInfo = data
        }
        openNextLevel()
        
    }
    
    func updatePlistFile() {
        let config = virusedLevelsInfo as NSArray
        config.writeToFile(getLevelsDataPath(), atomically: true)
    }
    
    func removeTutorial() {
        var data = self.virusedLevelsInfo
        data[currentLevel].removeValueForKey("tutorial")
        self.virusedLevelsInfo = data
    }
}
