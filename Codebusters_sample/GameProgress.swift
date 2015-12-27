//
//  GameProgress.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 02.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

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
            levelPacksInfo[currentLevelPack].levels[currentLevel + 1].updateValue(true, forKey: "isOpened")
        } else {
            openNextLevelPack()
            
            if currentLevelPack == 5 {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: "Finished")
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
    
    func getCurrentLevelData() -> [String : AnyObject] {
        var levelPacks = getLevelPacks()
        print(currentLevelPack)
        if (currentLevelPack == -1){
            currentLevelPack = levelPacks.count - 1
        }
        var levelPackData = levelPacks[currentLevelPack]
        let levels = levelPackData["levels"] as! [[String : AnyObject]]
        print(currentLevel)
        var levelIndex = currentLevel
        if (levelIndex == -1){
            levelIndex = levels.count - 1
        }
        
        
        var levelData = levels[levelIndex]
        
        
        
        if levelPackData["cellState"] as! String == DetailCellState.NonActive.rawValue {
            levelPackData.updateValue(DetailCellState.Active.rawValue, forKey: "cellState")
            levelPacks[currentLevelPack] = levelPackData
            
            writeToPropertyListFile(levelPacks)
        }
        
        
        if levelIndex == levels.count - 1 {
            if let detailType = levelPackData["detailType"] as? String {
                levelData.updateValue(detailType, forKey: "detailType")
            }
        } else {
            levelData.updateValue("Crystall", forKey: "detailType")
        }
        
        return levelData
    }
    
    func writeToPropertyListFile(levelPacks: [[String : AnyObject]]) {
        let config = getLevelsData()
        
        config.setValue(levelPacks, forKey: "levelPacks")
        config.writeToFile(getLevelsDataPath(), atomically: true)
    }
    
    func setNextLevel() {
        let levelPackData = getLevelPacks()[currentLevelPack]
        let levels = levelPackData["levels"] as! [[String : AnyObject]]
        
        if currentLevelPack == 5 && currentLevel == levels.count - 1 {
            let config = getLevelsData()
            config.setValue("True", forKey: "Finished")
            config.writeToFile(getLevelsDataPath(), atomically: true)
        }
        
        if currentLevel < levels.count - 1 {
            currentLevel++
        } else {
            currentLevel = -1
        }
    }
    
    func getCurrentLevelPackDetailType() -> DetailType {
        var levelPacks = getLevelPacks()
        var levelPackData = levelPacks[currentLevelPack]
        if let detailTypeString = levelPackData["detailType"] as? String {
            if let detailType = DetailType(rawValue: detailTypeString) {
                return detailType
            }
        }
        
        return DetailType.Crystall
    }
    
    func checkDetailCellState() {
        var levelPacks = getLevelPacks()
        var levelPackData = levelPacks[currentLevelPack]
        
        if levelPackData["cellState"] as! String != DetailCellState.Placed.rawValue {
            levelPackData.updateValue(DetailCellState.Placed.rawValue, forKey: "cellState")
            levelPacks[currentLevelPack] = levelPackData
            
            if currentLevelPack < levelPacks.count - 1 {
                if levelPacks[currentLevelPack + 1]["cellState"] as! String == DetailCellState.NonActive.rawValue {
                    var nextLevelPack = levelPacks[currentLevelPack + 1]
                    nextLevelPack.updateValue(DetailCellState.Active.rawValue, forKey: "cellState")
                    levelPacks[currentLevelPack + 1] = nextLevelPack
                }
            }
            
            writeToPropertyListFile(levelPacks)
        }
    }
    
    func finished() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("Finished") as? Bool == true {
            return true
        }
        
        return false
    }
    
    func isGameFinished() -> Bool {
        return levelPacksInfo[5].cellState == .Placed ? true : false
    }
}