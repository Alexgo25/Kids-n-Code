//
//  Helper.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 06.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

enum ActionType: String {
    case move = "Move",
    turn = "Turn",
    push = "Push",
    jump = "Jump",
    none = "none"
}

enum FloorPosition: Int {
    case ground = 0,
    first = 1,
    second = 2
}


struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Robot: UInt32 = 0b1  // 1
    static let Detail: UInt32 = 0b10  // 2
}

struct MenuConstants {
    static let CPUPosition = CGPoint(x: 1510, y: 815)
    static let HardDrivePosition = CGPoint(x: 1070, y: 732)
    static let RAM2Position = CGPoint(x: 1649, y: 663)
    static let RAM1Position = CGPoint(x: 1351, y: 663)
    static let BatteryPosition = CGPoint(x: 1194, y: 1001)
    static let FanPosition = CGPoint(x: 1668, y: 993)
}

func getDetailCellPosition(detailType: DetailType) -> CGPoint {
    switch detailType {
    case .Battery:
        return MenuConstants.BatteryPosition
    case .HardDrive:
        return MenuConstants.HardDrivePosition
    case .RAM1:
        return MenuConstants.RAM1Position
    case .RAM2:
        return MenuConstants.RAM2Position
    case .CPU:
        return MenuConstants.CPUPosition
    default:
        return MenuConstants.FanPosition
    }
}

struct Constants {
    static let ScreenSize = UIScreen.mainScreen().bounds
    
    static let ActionCellSize = CGSize(width: 239, height: 66)
    static let ActionCellFirstPosition = CGPoint(x: 1748, y: 1238)
    
    static let Button_MovePosition = CGPoint(x: -188, y: 156)
    static let Button_TurnPosition = CGPoint(x: -61, y: 224)
    static let Button_PushPosition = CGPoint(x: 94, y: 224)
    static let Button_JumpPosition = CGPoint(x: 215, y: 156)
    
    static let Button_StartPosition = CGPoint(x: 1760, y: 120) //CGPoint(x: 1769, y: 120)
    static let Button_ClearPosition = CGPoint(x: 1908, y: 229) //CGPoint(x: 1892, y: 289)
    static let Button_DebugPosition = CGPoint(x: 1612, y: 229) //CGPoint(x: 1648, y: 289)
    static let Button_PausePosition = CGPoint(x:103, y: 1440)
    static let Button_TipsPosition = CGPoint(x: 237, y: 1440)
    static let Button_RestartPosition = CGPoint(x: 1760, y: 324) //CGPoint(x: 370, y: 1440)
    
    static let Button_Restart_PauseViewPosition = CGPoint(x: 306, y: 950)
    static let Button_Continue_PauseViewPosition = CGPoint(x: 306, y: 1094)
    static let Button_Exit_PauseViewPosition = CGPoint(x: 306, y: 806)
    
    static let Button_Exit_EndLevelViewPosition = CGPoint(x: 672, y: 581.5)
    static let Button_Restart_EndLevelViewPosition = CGPoint(x: 1018.5, y: 581.5)
    static let Button_NextLevel_EndLevelViewPosition = CGPoint(x: 1363, y: 581.5)
    static let Battery_EndLevelViewPosition = CGPoint(x: 1032.5, y: 889)
    
    static let Robot_FirstBlockPosition = CGPoint(x: 315, y: 760)
    static let Block_FirstPosition = CGPoint(x: 125, y: 523)
    static let BlockFace_Size = CGSize(width: 204, height: 203)
    static let GroundFloor = CGFloat(561)
    static let FirstFloor = CGFloat(734)
    static let SecondFloor = CGFloat(937)
}

func getXBlockPosition(trackPosition: Int) -> CGFloat {
    return Constants.Block_FirstPosition.x + CGFloat(trackPosition) * Constants.BlockFace_Size.width
}

func getYBlockPosition(floorPosition: FloorPosition) -> CGFloat {
    return Constants.Block_FirstPosition.y + CGFloat(floorPosition.rawValue - 1) * Constants.BlockFace_Size.height
}

func getGameButtonPosition(type: GameButtonType) -> CGPoint {
    switch type {
    case .Clear:
        return Constants.Button_ClearPosition
    case .Debug:
        return Constants.Button_DebugPosition
    case .Pause:
        return Constants.Button_PausePosition
    case .Start:
        return Constants.Button_StartPosition
    case .Tips:
        return Constants.Button_TipsPosition
    case .Restart:
        return Constants.Button_RestartPosition
    case .Restart_PauseView:
        return Constants.Button_Restart_PauseViewPosition
    case .Continue_PauseView:
        return Constants.Button_Continue_PauseViewPosition
    case .Exit_PauseView:
        return Constants.Button_Exit_PauseViewPosition
    case .NextLevel_EndLevelView:
        return Constants.Button_NextLevel_EndLevelViewPosition
    case .Restart_EndLevelView:
        return Constants.Button_Restart_EndLevelViewPosition
    case .Exit_EndLevelView:
        return Constants.Button_Exit_EndLevelViewPosition
    case .Ok:
        return Constants.Button_TipsPosition
    }
}

func getActionButtonPosition(actionType: ActionType) -> CGPoint {
    switch actionType {
    case .move:
        return Constants.Button_MovePosition
    case .turn:
        return Constants.Button_TurnPosition
    case .push:
        return Constants.Button_PushPosition
    default:
        return Constants.Button_JumpPosition
    }
}

func getCGPointOfPosition(trackPosition: Int, floorPosition: FloorPosition) -> CGPoint {
    return CGPoint(x: getXRobotPosition(trackPosition), y: getYRobotPosition(floorPosition))
}

func getXRobotPosition(trackPosition: Int) -> CGFloat {
    return Constants.Robot_FirstBlockPosition.x + CGFloat(trackPosition - 1) * Constants.BlockFace_Size.width
}

func getYRobotPosition(floorPosition: FloorPosition) -> CGFloat {
    switch floorPosition {
    case .ground:
        return Constants.GroundFloor
    case .first:
        return Constants.FirstFloor
    case .second:
        return Constants.SecondFloor
    }
}

func getNextBlockPosition(blockPosition: CGPoint) -> CGPoint {
    return CGPoint(x: blockPosition.x + 317, y: blockPosition.y)
}

func getRobotAnimation(actionType: String, direction: Direction) -> [SKTexture] {
    var textures: [SKTexture] = []
    var directionString: String = ""
    
    if direction == .ToRight && actionType != "mistake" {
        directionString = "_ToRight"
    } else {
        directionString = "_ToLeft"
    }
    
    let atlasName = "Animation_\(actionType)\(directionString)"
    let atlas = SKTextureAtlas(named: atlasName)
    
    for var i = 1; i <= atlas.textureNames.count; i++ {
        textures.append(atlas.textureNamed("\(atlasName)_\(i)"))
    }
    
    return textures
}

func createLabel(text: String, fontColor: UIColor, fontSize: CGFloat, position: CGPoint) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: "Ubuntu Bold")
    label.text = text
    label.fontColor = fontColor
    label.fontSize = fontSize
    label.position = position
    label.zPosition = 1001
    label.verticalAlignmentMode = .Center
    return label
}