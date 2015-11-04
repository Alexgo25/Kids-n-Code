//
//  GameProgress.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 02.10.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

public class GameProgress {
    public static let sharedInstance = GameProgress()
    
    var currentLevel = 0
    var currentLevelPack = 0
    
    func changeSetting(key: String, value: String) {
        var settings = getLevelsData()["settings"] as! [String : AnyObject]
        settings.updateValue(value, forKey: key)
        
        let config = getLevelsData()
        
        config.setValue(settings, forKey: "settings")
        config.writeToFile(getLevelsDataPath(), atomically: true)
    }
    
    func getLevelPackData(levelPackIndex: Int) -> [Int] {
        var array: [Int] = []
        let levels = getLevelPacks()[levelPackIndex]["levels"] as! [[String : AnyObject]]
        for level in levels {
            let result = level["result"] as! Int
            let result_1 = level["result_1"] as! Int
            let result_2 = level["result_2"] as! Int
            
            if result < 1 {
                array.append(result)
            } else if result <= result_1 {
                array.append(3)
            } else if result <= result_2 {
                array.append(2)
            } else {
                array.append(1)
            }
        }
        
        return array
    }
    
    func writeResultOfCurrentLevel(result: Int) {
        
        var currentLevelData = getCurrentLevelData()
        let currentLevelResult = currentLevelData["result"] as! Int
        
        if result != 0 && currentLevelResult == 0 {
            openNextLevel()
        }
        
        if (result < currentLevelResult || result == 0 || currentLevelResult == 0) {
            currentLevelData.updateValue(result, forKey: "result")
        }
        
        var levelPacks = getLevelsData()["levelPacks"] as! [[String : AnyObject]]
        
        var levels = levelPacks[currentLevelPack]["levels"] as! [[String : AnyObject]]
        
        levels[currentLevel] = currentLevelData
        levelPacks[currentLevelPack]["levels"] = levels
        writeToPropertyListFile(levelPacks)
    }
    
    func removeTutorial() {
        var currentLevelData = getCurrentLevelData()
        currentLevelData.removeValueForKey("tutorial")
        
        var levelPacks = getLevelsData()["levelPacks"] as! [[String : AnyObject]]
        
        var levels = levelPacks[currentLevelPack]["levels"] as! [[String : AnyObject]]
        
        levels[currentLevel] = currentLevelData
        levelPacks[currentLevelPack]["levels"] = levels
        writeToPropertyListFile(levelPacks)
    }
    
    func getTutorialNumber() -> Int {
        if let tutorial = getCurrentLevelData()["tutorial"] as? Int {
            return tutorial
        }
        
        return 0
    }
    
    func openNextLevel() {
        if currentLevel < getLevelPackData(currentLevelPack).count - 1 {
            currentLevel++
            writeResultOfCurrentLevel(0)
            currentLevel--
        } else if currentLevelPack < 5 {
            let currentLevel = self.currentLevel
            let currentLevelPack = self.currentLevelPack
            self.currentLevel = 0
            self.currentLevelPack++
            writeResultOfCurrentLevel(0)
            self.currentLevel = currentLevel
            self.currentLevelPack = currentLevelPack
        }
    }
    
    func writePropertyListFileToDevice() {
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
    
    func getLevelPacks() -> [[String : AnyObject]] {
        let path = getLevelsDataPath()
        let config = NSDictionary(contentsOfFile: path)!
        
        let levelPacks = config["levelPacks"] as! [[String : AnyObject]]
        return levelPacks
    }
    
    func setLevel(levelPack: Int, level: Int) {
        currentLevel = level
        currentLevelPack = levelPack
    }
    
    func newGame(view: SKView) {
        if currentLevel != -1 {
            let scene = LevelScene(size: view.scene!.size)
            view.presentScene(scene, transition: SKTransition.crossFadeWithDuration(0.4))
        } else {
            goToMenu(view, robotTextImage: "\(Detail.sharedInstance.getDetailType().rawValue)_Text")
        }
    }
    
    func getLevelsData() -> NSDictionary {
        let path = getLevelsDataPath()
        let config = NSMutableDictionary(contentsOfFile: path)!
        return config
    }
    
    func getLevelsDataPath() -> String {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("Levels.plist")
        
        return fileURL.path!
    }
    
    func getCurrentLevelData() -> [String : AnyObject] {
        var levelPacks = getLevelPacks()
        var levelPackData = levelPacks[currentLevelPack]
        let levels = levelPackData["levels"] as! [[String : AnyObject]]
        var levelData = levels[currentLevel]
        
        if levelPackData["cellState"] as! String == DetailCellState.NonActive.rawValue {
            levelPackData.updateValue(DetailCellState.Active.rawValue, forKey: "cellState")
            levelPacks[currentLevelPack] = levelPackData
            
            writeToPropertyListFile(levelPacks)
        }
        
        
        if currentLevel == levels.count - 1 {
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
        if let value = getLevelsData()["Finished"] as? String {
            if value == "True" {
                return true
            }
        }
        return false
    }
    
    func isGameFinished() -> Bool {
        let levelPacks = GameProgress.sharedInstance.getLevelPacks()
        let lastLevelPack = levelPacks[5]
        
        if lastLevelPack["cellState"] as! String == "" {
            return true
        }
        
        return false
    }
    
    func goToMenu(view: SKView, robotTextImage: String = "") {
        currentLevel = -1
        currentLevelPack = -1
        if robotTextImage != "" {
            view.presentScene(MenuScene(robotTextImage: robotTextImage), transition: SKTransition.crossFadeWithDuration(0.4))
        } else {
            view.presentScene(MenuScene(), transition: SKTransition.crossFadeWithDuration(0.4))
        }
    }
    
    func getSettings() {
        let settings = getLevelsData()["settings"] as! [String : AnyObject]
        if settings["sounds"] as! String == "Off" {
            AudioPlayer.sharedInstance.soundsSwitcher.switchOff()
        }
        
        if settings["music"] as! String == "Off" {
            AudioPlayer.sharedInstance.musicSwitcher.switchOff()
        }
    }
    
    func getCurrentLevelNumber()->Int {
        return currentLevel
    }
    func getCurrentLevelPackNumber()->Int {
        return currentLevelPack
    }
}