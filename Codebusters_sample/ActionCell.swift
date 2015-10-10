//
//  ActionCell.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 05.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class ActionCell: SKSpriteNode {
    
    private var actionType: ActionType = .none
    static var cells: [ActionCell] = []
    static let cellsLayer = SKNode()
    private static var upperCellIndex = 0
    private let atlas = SKTextureAtlas(named: "ActionCells")

    private static let cellsLayerStartPosition = CGPoint(x: 1765, y: 1232)
    
    
    init(actionType: ActionType) {
        let texture = atlas.textureNamed("ActionCell_\(actionType.rawValue)")
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
        self.actionType = actionType
        position = getNextPosition()
        zPosition = 1002
        ActionCell.cells.append(self)
        alpha = 0
        runAction(SKAction.fadeInWithDuration(0.2))
        name = "\(ActionCell.cells.count - 1)"
        
        showLabel()
    }
    
    func getActionType() -> ActionType {
        return actionType
    }
    
    func getNextPosition() -> CGPoint {
        return CGPoint(x: 0, y: -CGFloat(ActionCell.cells.count) * texture!.size().height)
    }
    
    func highlightBegin() -> SKAction {
        return SKAction.runBlock() {
            self.texture = self.atlas.textureNamed("ActionCell_\(self.actionType.rawValue)_Highlighted")
        }
    }
    
    func highlightEnd() -> SKAction {
        return SKAction.runBlock() {
            self.texture = self.atlas.textureNamed("ActionCell_\(self.actionType.rawValue)")
        }
    }
    
    func showLabel() {
        let label = SKLabelNode(fontNamed: "Ubuntu Bold")
        
        switch actionType {
        case .move:
            label.text = "ШАГНУТЬ"
        case .jump:
            label.text = "ПРЫГНУТЬ"
        case .turn:
            label.text = "ПОВЕРНУТЬ"
        case .push:
            label.text = "ТОЛКНУТЬ"
        default:
            label.text = ""
        }
        
        label.fontSize = 23
        label.position = CGPoint(x: 19, y: 2)
        label.verticalAlignmentMode = .Center
        label.zPosition = 1
        addChild(label)
    }
    
    static func resetCellTextures() {
        let atlas = SKTextureAtlas(named: "ActionCells")
        for cell in cells {
            cell.texture = atlas.textureNamed("ActionCell_\(cell.actionType.rawValue)")
        }
    }
    
    static func resetCells() {
        cellsLayer.removeAllChildren()
        upperCellIndex = 0
        cells = []
        cellsLayer.position = cellsLayerStartPosition
    }
    
    static func isArrayOfCellsFull() -> Bool {
        return cells.count > 30
    }
    
    static func appendCell(actionType: ActionType) {
        if !isArrayOfCellsFull() {
            cellsLayer.addChild(ActionCell(actionType: actionType))
            if cellsCount() > 11 {
                appendCellWithMovingLayer()
            }
        }
    }
    
    static func deleteCell(index: Int) {
        if cells[index].alpha == 0 {
            return
        }
        
        let fadeOutAction = SKAction.group([SKAction.moveByX(-100, y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
        
        cells[index].runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
            self.moveCellsUpAfterDeleting(index)
            self.cells.removeAtIndex(index)
        } )
    }
    
    static func moveCellsUpAfterDeleting(index: Int) {
        for var i = index + 1; i < cellsCount(); i++ {
            cells[i].runAction(SKAction.moveByX(0, y: Constants.ActionCellSize.height + 2, duration: 0.25))
            cells[i].name = "\(i - 1)"
        }
        
        if upperCellIndex + 11 < cellsCount() {
            cells[upperCellIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
        } else {
            if upperCellIndex > 0 {
                cellsLayer.runAction(SKAction.moveByX(0, y: -Constants.ActionCellSize.height - 2, duration: 0.25))
                cells[upperCellIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
                upperCellIndex--
            }
        }
    }
    
    static func appendCellWithMovingLayer() {
        let downCellsQuantity = cellsCount() - 11 - upperCellIndex
        for var i = 0; i < downCellsQuantity; i++ {
            moveCellsLayerUp()
        }
    }
    
    static func moveCellsLayerToTop() {
        let topCellsQuantity = upperCellIndex
        for var i = 0; i < topCellsQuantity; i++ {
            moveCellsLayerDown()
        }
    }
    
    static func moveCellsLayerUp() {
        if canMoveCellsLayerUp() {
            cellsLayer.runAction(SKAction.moveByX(0, y: Constants.ActionCellSize.height + 2, duration: 0.25))
            cells[upperCellIndex].runAction(SKAction.fadeOutWithDuration(0.25))
            cells[upperCellIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
            
            upperCellIndex++
        }
    }
    
    static func moveCellsLayerDown() {
        if upperCellIndex > 0 {
            cellsLayer.runAction(SKAction.moveByX(0, y: -Constants.ActionCellSize.height - 2, duration: 0.25))
            cells[upperCellIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
            cells[upperCellIndex + 10].runAction(SKAction.fadeOutWithDuration(0.25))
            upperCellIndex--
        }
    }
    
    static func canMoveCellsLayerUp() -> Bool {
        return cellsCount() - upperCellIndex - 11 > 0
    }
    
    static func cellsCount() -> Int {
        return cells.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
