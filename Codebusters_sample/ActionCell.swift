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
    static let actionCellSize = CGSize(width: 239, height: 66)
    static var selectedIndexes : [Int] = []
    
    var actionType: ActionType
    private static var upperCellIndex = 0
    private var cellBackground: SKSpriteNode
    var selected = false
    var numberOfRepeats = 1
    
    
    private static let cellsLayerStartPosition = CGPoint(x: 1765, y: 1232)
    static var cells: [ActionCell] = []
    static let cellsLayer = SKNode()
    
    init(actionType: ActionType) {
        let atlas = SKTextureAtlas(named: "ActionCells")
        let texture = atlas.textureNamed("ActionCell_\(actionType)")
        cellBackground = SKSpriteNode(texture: texture)
        cellBackground.zPosition = -2
        self.actionType = actionType
        
        super.init(texture: nil, color: SKColor.clearColor(), size: texture.size())
        self.userInteractionEnabled = true
        addChild(cellBackground)
        position = getNextPosition()
        zPosition = 2001
        ActionCell.cells.append(self)
        alpha = 0
        runAction(SKAction.fadeInWithDuration(0.2))
        name = "\(ActionCell.cells.count - 1)"
        
        showLabel()
    }

    func getNextPosition() -> CGPoint {
        return CGPoint(x: 0, y: -CGFloat(ActionCell.cells.count) * cellBackground.size.height)
    }
    
    func highlightBegin() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock() {
            self.cellBackground.texture = atlas.textureNamed("ActionCell_\(self.actionType)_Highlighted")
        }
    }
    
    func highlightEnd() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock() {
            self.cellBackground.texture = atlas.textureNamed("ActionCell_\(self.actionType)")
        }
    }
    
    func setSelected() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock({
            if (ActionCell.selectedIndexes.count == 0) {
                self.cellBackground.texture = atlas.textureNamed("ActionCell_selected")
                self.selected = true
                ActionCell.selectedIndexes.append(Int(self.name!)!)
                print(ActionCell.selectedIndexes)
                NSNotificationCenter.defaultCenter().postNotificationName(kActionCellSelectedKey , object: NotificationZombie.sharedInstance)
            }
            else {
                let index = Int(self.name!)!
                var findElement = false
                for element in ActionCell.selectedIndexes {
                    if (index == element + 1 || index == element - 1) {
                        findElement = true
                        break
                    }
                }
                if (findElement) {
                    self.cellBackground.texture = atlas.textureNamed("ActionCell_selected")
                    self.selected = true
                    ActionCell.selectedIndexes.append(Int(self.name!)!)
                    print(ActionCell.selectedIndexes)
                }
            }
            
        })
    }
    
    func deselect() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock() {
            var findElement = true
            let value = Int(self.name!)!
            if (ActionCell.selectedIndexes.contains(value - 1) && ActionCell.selectedIndexes.contains(value + 1)) {
                findElement = false
            }
            if (findElement) {
                self.cellBackground.texture = atlas.textureNamed("ActionCell_\(self.actionType)")
                self.selected = false
                let element = Int(self.name!)!
                let index = ActionCell.selectedIndexes.indexOf(element)
                ActionCell.selectedIndexes.removeAtIndex(index!)
                print(ActionCell.selectedIndexes)
            }
            if (ActionCell.selectedIndexes.count == 0){
                NSNotificationCenter.defaultCenter().postNotificationName(kActionCellDeselectAllKey, object: NotificationZombie.sharedInstance)
            }
            
        }
    }
    
    static func deselectAll() {
        for cell in ActionCell.cells {
            cell.runAction(cell.deselect())
        }
    }
//markLabels
    func showLabel() {
        let label = SKLabelNode(fontNamed: "Ubuntu Bold")
        
        switch actionType {
        case .Move:
            label.text = kStepButtonLabel
        case .Jump:
            label.text = kJumpButtonLabel
        case .Turn:
            label.text = kTurnButtonLabel
        case .Push:
            label.text = kPushButtonLabel
        default:
            label.text = ""
        }
        
        label.fontSize = 23
        label.position = CGPoint(x: 19, y: 2)
        label.verticalAlignmentMode = .Center
        label.zPosition = -1
        addChild(label)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //tetect touch
        print("ActionCell is touched")
        if (selected) {
            self.runAction(deselect())
            //Drop notification to LevelScene
        }
        else {
            self.runAction(setSelected())
            //Drop notification to LevelScene
        }
    }
    
    static func resetCellTextures() {
        let atlas = SKTextureAtlas(named: "ActionCells")
        for cell in cells {
            cell.cellBackground.texture = atlas.textureNamed("ActionCell_\(cell.actionType)")
        }
    }
    
    static func resetCells() {
        cellsLayer.removeAllChildren()
        upperCellIndex = 0
        cellsLayer.position = cellsLayerStartPosition
        cells.removeAll(keepCapacity: false)
    }
    
    static func isArrayOfCellsFull() -> Bool {
        return cells.count > 29
    }
    
    static func appendCell(actionType: ActionType) {
        if !isArrayOfCellsFull() {
            cellsLayer.addChild(ActionCell(actionType: actionType))
            if cellsCount() > 11 {
                appendCellWithMovingLayer()
            }
        }
    }
    
    static func deleteCell(index: Int, direction: Direction) {
        if cells[index].alpha == 0 {
            return
        }
        
        let fadeOutAction = SKAction.group([SKAction.moveByX(100 * CGFloat(direction.rawValue), y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
        
        cells[index].runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
            self.moveCellsUpAfterDeleting(index)
            self.cells.removeAtIndex(index)
        } )
    }
    
    static func moveCellsUpAfterDeleting(index: Int) {
        for var i = index + 1; i < cellsCount(); i++ {
            cells[i].runAction(SKAction.moveByX(0, y: actionCellSize.height + 2, duration: 0.25))
            cells[i].name = "\(i - 1)"
        }
        
        if upperCellIndex + 11 < cellsCount() {
            cells[upperCellIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
        } else {
            if upperCellIndex > 0 {
                cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 2, duration: 0.25))
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
            cellsLayer.runAction(SKAction.moveByX(0, y: actionCellSize.height + 2, duration: 0.25))
            cells[upperCellIndex].runAction(SKAction.fadeOutWithDuration(0.25))
            cells[upperCellIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
            
            upperCellIndex++
        }
    }
    
    static func moveCellsLayerDown() {
        if upperCellIndex > 0 {
            cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 2, duration: 0.25))
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
