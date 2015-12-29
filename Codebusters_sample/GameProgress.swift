//
//  GameProgress.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 02.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

let kFinishedKey = "Finished"
let kIsOpenedKey = "isOpened"

public class GameProgress {
    var currentLevel = 0
    var currentLevelPack = -1
    var currentDetailType: DetailType = .Crystall
    
    
    var levelPacksInfo: [LevelPackData] = [] {
        didSet {
            updateLevelsFile()
        }
    }
    
    init() {
        writePListToDevice()
        getLevelPacks()
    }
    
    func getLevelConfiguration() -> LevelConfiguration {
        return LevelConfiguration(info: levelPacksInfo[currentLevelPack].levels[currentLevel])
    }
    
    func setLevel(levelPack: Int, level: Int) {
        if levelPack != -1 {
            currentDetailType = levelPacksInfo[levelPack].detailType
        }
        
        currentLevelPack = levelPack
        currentLevel = level
    }
    
    func openNextLevelPack() {
        var levelPacks = levelPacksInfo
        
        if levelPacks[currentLevelPack + 1].cellState == .NonActive {
            levelPacks[currentLevelPack + 1].cellState = .Active
        }
        
        levelPacks[currentLevelPack].cellState = .Placed
        levelPacksInfo = levelPacks
    }
    
    func openNextLevel() {
        let levelsCount = levelPacksInfo[currentLevelPack].levels.count
        
        guard levelPacksInfo[currentLevelPack].levels[currentLevel]["result"] as! Int > 0 else { return }
        
        if currentLevel + 1 < levelsCount {
            levelPacksInfo[currentLevelPack].levels[currentLevel + 1].updateValue(true, forKey: kIsOpenedKey)
        } else {
            openNextLevelPack()
            
            if currentLevelPack == 5 {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: kFinishedKey)
            }
        }
    }
    
    func setNextLevel() {
        let levelsCount = levelPacksInfo[currentLevelPack].levels.count
        
        guard levelPacksInfo[currentLevelPack].levels[currentLevel]["result"] as! Int > 0 else { return }
        
        if currentLevel < levelsCount - 1 {
            currentLevel++
        } else {
            currentLevelPack = -1
            currentLevel = 0
        }
    }
    
    func updateLevelsFile() {
        var array: [[String: AnyObject]] = []
        for levelPack in levelPacksInfo {
            array.append(levelPack.dictionary)
        }
        let config = NSArray(array: array)
        config.writeToFile(getLevelsDataPath(), atomically: true)
    }
    
    func writeResultOfCurrentLevel(result: Int) {
        var levelPacksInfo = self.levelPacksInfo
        
        let currentResult = levelPacksInfo[currentLevelPack].levels[currentLevel]["result"] as! Int
        if result < currentResult || currentResult == 0 {
            levelPacksInfo[currentLevelPack].levels[currentLevel].updateValue(result, forKey: "result")
            self.levelPacksInfo = levelPacksInfo
            openNextLevel()
        }
    }
    
    func removeTutorial() {
        var levelPacksInfo = self.levelPacksInfo
        levelPacksInfo[currentLevelPack].levels[currentLevel].removeValueForKey("tutorial")
        self.levelPacksInfo = levelPacksInfo
    }
    
    func writePListToDevice() {
        let path = getLevelsDataPath()
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            if let bundle = NSBundle.mainBundle().pathForResource("Levels", ofType: "plist") {
                do {
                    try fileManager.copyItemAtPath(bundle, toPath: path)
                } catch _ {
                    print("mh")
                }
            }
        } else {
            if let _ = NSMutableDictionary(contentsOfFile: path) {
                updatePList()
                do {
                    try fileManager.removeItemAtPath(path)
                }
                catch _ {
                    print("123")
                }
                writePListToDevice()
                updateLevelsFile()
            }
        }
    }
    
    func updatePList() {
        let path = getLevelsDataPath()
        let config = NSMutableDictionary(contentsOfFile: path)!
        let levelPacks = config["levelPacks"] as! [[String : AnyObject]]
        
        levelPacksInfo = levelPacks.map {
            LevelPackData(levelPackData: $0)
        }
        
        for var i = 0; i < levelPacksInfo.count; i++ {
            var levelPackInfo = levelPacksInfo[i]
            var levels = levelPackInfo.levels
            for var j = 0; j < levels.count; j++ {
                var level = levels[j]
                let result = level["result"] as! Int
                if result == -1 {
                    level.updateValue(false, forKey: kIsOpenedKey)
                    level.updateValue(0, forKey: "result")
                } else {
                    level.updateValue(true, forKey: kIsOpenedKey)
                }
                levels[j] = level
            }
            
            levelPackInfo.levels = levels
            levelPacksInfo[i] = levelPackInfo
        }
    }
    
    func getLevelPacks() {
        let path = getLevelsDataPath()
        let plist = NSArray(contentsOfFile: path)! as! [[String: AnyObject]]
        
        levelPacksInfo = plist.map {
            LevelPackData(levelPackData: $0)
        }
    }
    
    func getLevelsData() -> NSArray {
        let path = getLevelsDataPath()
        let config = NSArray(contentsOfFile: path)! as! [[String: AnyObject]]
        return config
    }
    
    func getLevelsDataPath() -> String {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("Levels.plist")
        
        return fileURL.path!
    }
    
    func finished() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(kFinishedKey) as? Bool == true {
            return true
        }
        
        return false
    }
    
    func isGameFinished() -> Bool {
        return levelPacksInfo[5].cellState == .Placed ? true : false
    }
}