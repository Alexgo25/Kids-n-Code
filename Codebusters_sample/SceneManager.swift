//
//  SceneManager.swift
//  Kids'n'Code
//
//  Created by Владислав Кутейников on 23.12.15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

class SceneManager {
    enum SceneType {
        case Menu,
        CurrentLevel,
        NextLevel,
        Level(Int, Int)
    }
    
    var currentLevel: Int {
        return gameProgressManager.currentLevel
    }
    
    var currentLevelPack: Int {
        return gameProgressManager.currentLevelPack
    }
    
    var gameProgressManager: GameProgress
    
    let view: SKView
    let size = CGSize(width: 2048, height: 1536)
    
    var levelPacksInfo: [LevelPackData] {
        return gameProgressManager.levelPacksInfo
    }
    
    var currentLevelInfo: LevelConfiguration?
    
    init(view: SKView) {
        self.view = view
        gameProgressManager = GameProgress()
    }
    
    func presentScene(scene: SceneTemplate) {
        scene.sceneManager = self
        
        let transition = SKTransition.fadeWithDuration(0.5)
        if (self.view.scene != nil){
            let currentScene = self.view.scene!
            currentScene.removeAllActions()
            currentScene.removeAllChildren()
            currentScene.removeFromParent()
        }
        self.view.presentScene(scene, transition: transition)
        
    }
    
    func presentScene(sceneType: SceneType) {
        switch sceneType {
        case .Menu:
            if currentLevelPack == -1 && gameProgressManager.currentDetailType != .Crystall {
                presentScene(MenuScene(robotTextImage: gameProgressManager.currentDetailType.rawValue + kDetailTextSuffix, data: levelPacksInfo))
            } else {
                if (self.view.scene != nil){
                    let currentScene = self.view.scene!
                    currentScene.removeAllActions()
                    currentScene.removeAllChildren()
                    currentScene.removeFromParent()
                }
                presentScene(MenuScene(data: levelPacksInfo))
            }
        case .Level(let levelPack, let levelNumber):
            gameProgressManager.setLevel(levelPack, level: levelNumber)
            if currentLevelPack == -1 {
                presentScene(.Menu)
                break
            }
            let levelConfiguration = gameProgressManager.getLevelConfiguration()
            currentLevelInfo = levelConfiguration
            if (self.view.scene != nil){
                let currentScene = self.view.scene!
                currentScene.removeAllActions()
                currentScene.removeAllChildren()
                currentScene.removeFromParent()
            }
            presentScene(LevelScene(levelInfo: levelConfiguration))
        case .NextLevel:
            gameProgressManager.setNextLevel()
            if currentLevelPack == -1 {
                presentScene(.Menu)
                break
            }
            currentLevelInfo = gameProgressManager.getLevelConfiguration()
            fallthrough
        case .CurrentLevel:
            if currentLevelInfo != nil {
                if (self.view.scene != nil){
                    let currentScene = self.view.scene!
                    currentScene.removeAllActions()
                    currentScene.removeAllChildren()
                    currentScene.removeFromParent()
                }
                presentScene(LevelScene(levelInfo: currentLevelInfo!))
            }
        }
    }
}