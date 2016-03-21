//
//  ActionCell.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 05.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

let bottomY : CGFloat = -800.0
let topY : CGFloat = 0.0

class ActionCell: SKSpriteNode  {
    static let actionCellSize = CGSize(width: 239, height: 66)
    static var selectedIndexes : [Int] = []
    static var repeatRectangles : [LoopControlRepeatRect] = []
    static var nodesInProgram : [SKSpriteNode] = []
    
    
    var actionType: ActionType
    private static var upperNodeIndex = 0
    var cellBackground: SKSpriteNode
    var selected = false
    var numberOfRepeats = 1
    var index = 0
    
    var bottomRect : LoopControlRepeatRect!
    var topRect : LoopControlRepeatRect!
    
    
    
    private static let cellsLayerStartPosition = CGPoint(x: 1765, y: 1232)
    static var cells: [ActionCell] = []
    static let cellsLayer = SKNode()
    
    init(actionType: ActionType) {
        let atlas = SKTextureAtlas(named: "ActionCells")
        let texture = atlas.textureNamed("ActionCell")
        cellBackground = SKSpriteNode(texture: texture)
        cellBackground.zPosition = -2
        self.actionType = actionType
        
        super.init(texture: nil, color: SKColor.clearColor(), size: texture.size())
        self.userInteractionEnabled = true
        addChild(cellBackground)
        position = getNextPosition()
        zPosition = 2001
        ActionCell.cells.append(self)
        ActionCell.nodesInProgram.append(self)
        alpha = 0
        runAction(SKAction.fadeInWithDuration(0.2))
        index = ActionCell.cells.count - 1
        showLabel()
    }
// Protocol declaration
    
    
// End
    
    func getNextPosition() -> CGPoint {
        if (ActionCell.cells.count == 0) {
            return CGPoint(x: 0, y: -CGFloat(ActionCell.cells.count) * cellBackground.size.height)
        }
        else {
            let prevPos = ActionCell.cells[ActionCell.cells.count - 1].position
            return CGPoint(x: 0, y: prevPos.y - cellBackground.size.height)
        }
       
    }
    
    func highlightBegin() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock() {
            self.cellBackground.texture = atlas.textureNamed("ActionCell_Highlighted")
        }
    }
    
    
    
    func highlightEnd() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock() {
            self.cellBackground.texture = atlas.textureNamed("ActionCell")
        }
    }
    
    func setSelected() -> SKAction {
        if (self.numberOfRepeats == 1) {
            let atlas = SKTextureAtlas(named: "ActionCells")
            return SKAction.runBlock({
                if (ActionCell.selectedIndexes.count == 0) {
                    self.cellBackground.texture = atlas.textureNamed("ActionCell_selected")
                    self.selected = true
                    ActionCell.selectedIndexes.append(ActionCell.cells.indexOf(self)!)
                    print(ActionCell.selectedIndexes)
                    NSNotificationCenter.defaultCenter().postNotificationName(kActionCellSelectedKey , object: NotificationZombie.sharedInstance)
                }
                else {
                    var findElement = false
                    for element in ActionCell.selectedIndexes {
                        if (self.index == element + 1 || self.index == element - 1) {
                            findElement = true
                            break
                        }
                    }
                    if (findElement) {
                        self.cellBackground.texture = atlas.textureNamed("ActionCell_selected")
                        self.selected = true
                        ActionCell.selectedIndexes.append(self.index)
                        print(ActionCell.selectedIndexes)
                    }
                }
                
            })
        }
        else {
            return SKAction()
        }
        
    }
    
    func deselect() -> SKAction {
        let atlas = SKTextureAtlas(named: "ActionCells")
        return SKAction.runBlock() {
            var findElement = true
            let value = self.index
            if (ActionCell.selectedIndexes.contains(value - 1) && ActionCell.selectedIndexes.contains(value + 1)) {
                findElement = false
            }
            if (findElement) {
                self.cellBackground.texture = atlas.textureNamed("ActionCell")
                self.selected = false
                let element = self.index
                let cindex = ActionCell.selectedIndexes.indexOf(element)
                ActionCell.selectedIndexes.removeAtIndex(cindex!)
                print(ActionCell.selectedIndexes)
            }
            if (ActionCell.selectedIndexes.count == 0){
                NSNotificationCenter.defaultCenter().postNotificationName(kActionCellDeselectAllKey, object: NotificationZombie.sharedInstance)
            }
            
        }
    }
    
    static func deselectAll() {
        let atlas = SKTextureAtlas(named: "ActionCells")
        for (var i = 0 ; i < selectedIndexes.count ; i++) {
            let cell = ActionCell.cells[selectedIndexes[i]]
            let deselectAction = SKAction.runBlock({
                cell.cellBackground.texture = atlas.textureNamed("ActionCell")
                cell.selected = false
                cell.numberOfRepeats = 1
            })
            cell.runAction(deselectAction)
            
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kActionCellDeselectAllKey, object: NotificationZombie.sharedInstance)
        ActionCell.selectedIndexes = []
    }
    
    static func deselectAll(numberOfRepeats : Int) {
        let atlas = SKTextureAtlas(named: "ActionCells")
        var cellsToAppend : [ActionCell] = []
        for (var i = 0 ; i < selectedIndexes.count ; i++) {
            let cell = ActionCell.cells[selectedIndexes[i]]
            let deselectAction = SKAction.runBlock({
                cell.cellBackground.texture = atlas.textureNamed("ActionCell")
                cell.selected = false
                cell.numberOfRepeats = numberOfRepeats
            })
            cellsToAppend.append(cell)
            cell.runAction(deselectAction)
            
        }
        let minIndex = ActionCell.selectedIndexes.minElement()
        let cell = ActionCell.cells[minIndex!]
        let loopRect = LoopControlRepeatRect(actionCell: cell, numberOfRepeats: numberOfRepeats)
        loopRect.repeatCells = cellsToAppend
        if (minIndex != 0) {
            ActionCell.cells[minIndex! - 1].bottomRect = loopRect
        }
        ActionCell.cells[minIndex!].topRect = loopRect
        cellsLayer.addChild(loopRect)
        let nodeIndex = nodesInProgram.indexOf(cell)
        nodesInProgram.insert(loopRect, atIndex: nodeIndex!)
        if (canMoveCellsLayerUp()) {
            nodesInProgram[upperNodeIndex + 11].runAction(SKAction.fadeOutWithDuration(0.25))
            }
        NSNotificationCenter.defaultCenter().postNotificationName(kActionCellDeselectAllKey, object: NotificationZombie.sharedInstance)
        ActionCell.selectedIndexes = []


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
        case .Catch:
            label.text = kCatchButtonLabel
        default:
            label.text = ""
        }
        
        label.fontSize = 23
        label.position = CGPoint(x: 0, y: 2)
        label.verticalAlignmentMode = .Center
        label.zPosition = -1
        addChild(label)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //detect touch
        print("ActionCell is touched")
        if (LevelScene.loopsEnabled) {
            if (selected) {
                self.runAction(deselect())
                //Drop notification to LevelScene
            }
            else {
                self.runAction(setSelected())
                //Drop notification to LevelScene
            }
        }
    }
    
    //search cell while deleting
    
    
    
    static func resetCellTextures() {
        let atlas = SKTextureAtlas(named: "ActionCells")
        for cell in cells {
            cell.cellBackground.texture = atlas.textureNamed("ActionCell")
        }
    }
    
    static func resetCells() {
        cellsLayer.removeAllChildren()
        upperNodeIndex = 0
        cellsLayer.position = cellsLayerStartPosition
        cells.removeAll(keepCapacity: false)
        repeatRectangles.removeAll(keepCapacity: false)
        nodesInProgram.removeAll(keepCapacity: false)
    }
    
    static func isArrayOfNodesFull() -> Bool {
        return nodesInProgram.count > 29
    }
    
    static func appendCell(actionType: ActionType) {
        if !isArrayOfNodesFull() {
            cellsLayer.addChild(ActionCell(actionType: actionType))
            if (nodesInProgram.count > 11) {
                appendCellWithMovingLayer()
            }
        }
    }
    
    static func deleteCell(index: Int, direction: Direction) {
        if cells[index].alpha == 0 {
            return
        }
        
        if (cells[index].selected) {
            return
        }
        
        if (cells[index].topRect == nil) {
            let fadeOutAction = SKAction.group([SKAction.moveByX(100 * CGFloat(direction.rawValue), y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
            
               cells[index].runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
                let deleteIndex = nodesInProgram.indexOf(cells[index])!
                self.moveCellsUpAfterDeleting(deleteIndex)
                self.nodesInProgram.removeAtIndex(deleteIndex)
                self.cells.removeAtIndex(index)
            } )
        }
        
        else {
            if (cells[index].topRect.repeatCells.count > 1 ) {
                    let fadeOutAction = SKAction.group([SKAction.moveByX(100 * CGFloat(direction.rawValue), y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
                    cells[index].runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
                    cells[index].topRect.repeatCells.removeLast()
                    let deleteIndex = nodesInProgram.indexOf(cells[index])!
                    self.moveCellsUpAfterDeleting(deleteIndex)
                    self.nodesInProgram.removeAtIndex(deleteIndex)
                    self.cells.removeAtIndex(index)
                    } )
            }
            else {
                let rect = cells[index].topRect!
                let fadeOutAction = SKAction.group([SKAction.moveByX(100 * CGFloat(direction.rawValue), y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
                cells[index].runAction(SKAction.sequence([fadeOutAction , SKAction.runBlock({
                    AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3")
                }) , SKAction.removeFromParent()]))
                rect.runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        let rindex = repeatRectangles.indexOf(rect)
                        let deleteIndex = nodesInProgram.indexOf(cells[index])!
                        repeatRectangles.removeAtIndex(rindex!)
                        cells.removeAtIndex(index)
                        nodesInProgram.removeAtIndex(deleteIndex - 1)
                        nodesInProgram.removeAtIndex(deleteIndex - 1)
                        self.moveNodesAfterDeletingTwo(deleteIndex)
                    })
                } )
            }
        }
        
        
    }
    
    static func deleteRect(index : Int , direction : Direction) {
        let rcells = repeatRectangles[index].repeatCells
        rcells.first?.topRect = nil
        let pindex = cells.indexOf(rcells.first!)
        if (pindex > 0 ) {
            cells[pindex! - 1].bottomRect = nil
        }
        let fadeOutAction = SKAction.group([SKAction.moveByX(100 * CGFloat(direction.rawValue), y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
        repeatRectangles[index].runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
            let nIndex = nodesInProgram.indexOf(repeatRectangles[index])
            repeatRectangles.removeAtIndex(index)
            nodesInProgram.removeAtIndex(nIndex!)
        } )
        
        for cell in rcells {
            cell.runAction(SKAction.moveByX( -61, y: 0, duration: 0.2))
            cell.numberOfRepeats = 1
        }
        selectedIndexes = []
        moveCellsUpAfterDeleting(pindex! - 1)
        getRectIndexes()

    }
    
    static func moveCellsUpAfterDeleting(index: Int) {
        for var i = index + 1; i < nodesInProgram.count; i++ {
            nodesInProgram[i].runAction(SKAction.moveByX(0, y: actionCellSize.height + 4, duration: 0.25))
            if nodesInProgram[i] is ActionCell {
                let cell = nodesInProgram[i] as! ActionCell
                cell.index = cells.indexOf(cell)!
            }
            
        }
        
        if upperNodeIndex + 11 < nodesInProgram.count {
            nodesInProgram[upperNodeIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
        } else {
            if upperNodeIndex > 0 {
                cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 4, duration: 0.25))
                nodesInProgram[upperNodeIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
                upperNodeIndex--
            }
        }
    }
    
    static func moveNodesAfterDeletingTwo(index : Int) {
        for var i = index - 1 ; i < nodesInProgram.count; i++ {
            nodesInProgram[i].runAction(SKAction.moveByX(0, y: 2 * actionCellSize.height + 8, duration: 0.25))
            if nodesInProgram[i] is ActionCell {
                let cell = nodesInProgram[i] as! ActionCell
                cell.index -= 1
            }
            
        }
        
        if upperNodeIndex + 11 < nodesInProgram.count {
            nodesInProgram[upperNodeIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
        } else {
            if upperNodeIndex > 0 {
                cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 4, duration: 0.25))
                nodesInProgram[upperNodeIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
                upperNodeIndex--
            }
        }

    }
    
    static func appendCellWithMovingLayer() {
        let downCellsQuantity = nodesInProgram.count - 11 - upperNodeIndex
        for var i = 0; i < downCellsQuantity; i++ {
            moveCellsLayerUp()
        }
    }
    
    
    static func moveCellsLayerToTop() {
        let topNodesQuantity = upperNodeIndex
        for var i = 0; i < topNodesQuantity; i++ {
            moveCellsLayerDown()
        }
    }
    
    static func moveCellsLayerUp() {
        //move cells layer when adding a new cell
            if canMoveCellsLayerUp() {
                cellsLayer.runAction(SKAction.moveByX(0, y: actionCellSize.height + 4, duration: 0.25))
                nodesInProgram[upperNodeIndex].runAction(SKAction.fadeOutWithDuration(0.25))
                nodesInProgram[upperNodeIndex + 11].runAction(SKAction.fadeInWithDuration(0.25))
                
                upperNodeIndex++
            }
    }
    
    static func moveCellsLayerDown() {   //move layer when
        if upperNodeIndex > 0 {
            cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 4, duration: 0.25))
            nodesInProgram[upperNodeIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
            nodesInProgram[upperNodeIndex + 10].runAction(SKAction.fadeOutWithDuration(0.25))
            upperNodeIndex--
        }
    }
    
    static func canMoveCellsLayerUp() -> Bool {
        return nodesInProgram.count - 11 > 0
    }
    
    static func cellsCount() -> Int {
        return cells.count
    }
    
    static func repeatRectsCount() -> Int {
        return repeatRectangles.count
    }
    
    static func getTopSelectedIndex()->Int {
        var index = -1
        for cell in ActionCell.cells {
            if (cell.selected) {
                index = ActionCell.cells.indexOf(cell)!
                break
            }
        }
        return index
    }
    
    static func moveCellsDownWhenAddingRect() {
        let firstSelectedIndex = selectedIndexes.minElement()!
        for (var i = firstSelectedIndex ; i < ActionCell.cells.count ; i++) {
            let cell = ActionCell.cells[i]
            let action : SKAction!
            if (cell.selected) {
                action = SKAction.moveByX(61, y: -actionCellSize.height - 4 , duration: 0.25)
                cell.runAction(action)
            }
            else {
                cell.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 4, duration: 0.25))
            }
        }
        for rect in repeatRectangles {
            if (rect.position.y < cells[firstSelectedIndex].position.y) {
                rect.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 4, duration: 0.25))
            }
        }

    }
    
    static func getRectIndexes() {
        for (var i = 0 ; i < repeatRectangles.count ; i++) {
            repeatRectangles[i].name = "\(i)"
        }
    }
    
    
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
