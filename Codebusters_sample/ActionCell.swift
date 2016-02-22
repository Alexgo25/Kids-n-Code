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
    
    var actionType: ActionType
    private static var upperCellIndex = 0
    var cellBackground: SKSpriteNode
    var selected = false
    var numberOfRepeats = 1
    
    var bottomRect : LoopControlRepeatRect!
    var topRect : LoopControlRepeatRect!
    
    
    
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
// Protocol declaration
    
    
// End
    
    func getNextPosition() -> CGPoint {
        if (ActionCell.cells.count == 0) {
            return CGPoint(x: 0, y: -CGFloat(ActionCell.cells.count) * cellBackground.size.height)
        }
        else {
            let prevPos = ActionCell.cells[ActionCell.cells.count - 1].position
            //return CGPoint(x: 0, y: -CGFloat(ActionCell.cells.count) * cellBackground.size.height)
            return CGPoint(x: 0, y: prevPos.y - cellBackground.size.height)
        }
       
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
        if (self.numberOfRepeats == 1) {
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
        else {
            return SKAction()
        }
        
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
        let atlas = SKTextureAtlas(named: "ActionCells")
        for (var i = 0 ; i < selectedIndexes.count ; i++) {
            let cell = ActionCell.cells[selectedIndexes[i]]
            let deselectAction = SKAction.runBlock({
                cell.cellBackground.texture = atlas.textureNamed("ActionCell_\(cell.actionType)")
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
                cell.cellBackground.texture = atlas.textureNamed("ActionCell_\(cell.actionType)")
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
        if (minIndex! == 0) {
            loopRect.state = .ShouldDisappearFromTop
        }
        else {
            ActionCell.cells[minIndex! - 1].bottomRect = loopRect
            loopRect.state = .Normal
        }
        ActionCell.cells[minIndex!].topRect = loopRect
        cellsLayer.addChild(loopRect)
        if (canMoveCellsLayerUp()) {
            if (bottomActionCellShouldFadeOut()) {
                let lastIndex = cells.indexOf(visibleCells().last!)!
                cells[lastIndex].runAction(SKAction.fadeOutWithDuration(0.25))
            }
            else {
                let lastIndex = repeatRectangles.indexOf(visibleRects().last!)!
                repeatRectangles[lastIndex].runAction(SKAction.fadeOutWithDuration(0.25))
            }
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
        default:
            label.text = ""
        }
        
        label.fontSize = 23
        label.position = CGPoint(x: 19, y: 2)
        label.verticalAlignmentMode = .Center
        label.zPosition = -1
        addChild(label)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //detect touch
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
    
    //search cell while deleting
    
    
    
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
        repeatRectangles.removeAll(keepCapacity: false)
    }
    
    static func isArrayOfCellsFull() -> Bool {
        return cells.count > 29
    }
    
    static func appendCell(actionType: ActionType) {
        if !isArrayOfCellsFull() {
            cellsLayer.addChild(ActionCell(actionType: actionType))
            if (visibleCells().count + visibleRects().count > 11) {
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
                self.moveCellsUpAfterDeleting(index)
                self.cells.removeAtIndex(index)
            } )
        }
        
        else {
            if (cells[index].topRect.repeatCells.count > 1 ) {
                    let fadeOutAction = SKAction.group([SKAction.moveByX(100 * CGFloat(direction.rawValue), y: 0, duration: 0.2), SKAction.fadeOutWithDuration(0.2)])
                    cells[index].runAction(SKAction.sequence([fadeOutAction, SKAction.runBlock() { AudioPlayer.sharedInstance.playSoundEffect("Sound_ActionCellRemoving.mp3") }, SKAction.removeFromParent()]), completion: {
                    cells[index].topRect.repeatCells.removeLast()
                    //cells[index].topRect.changeCell(cells[index + 1])
                    self.moveCellsUpAfterDeleting(index)
                        
                    self.cells.removeAtIndex(index)
                    } )
            }
            else {
                return
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
            repeatRectangles.removeAtIndex(index)
        } )
        
        for cell in rcells {
            cell.runAction(SKAction.moveByX( -61, y: 0, duration: 0.2))
        }
        moveCellsUpAfterDeleting(pindex! - 1)
        getRectIndexes()

    }
    
    static func moveCellsUpAfterDeleting(index: Int) {
        for var i = index + 1; i < cellsCount(); i++ {
            cells[i].runAction(SKAction.moveByX(0, y: actionCellSize.height + 2, duration: 0.25))
            cells[i].name = "\(i - 1)"
            if cells[i].topRect != nil {
                cells[i].topRect.runAction(SKAction.moveByX(0, y: actionCellSize.height + 2, duration: 0.25))
            }
        }
        
        /*var rectsToDelete : [LoopControlRepeatRect] = []
        for rect in repeatRectangles {
            if (rect.lowerCellIndex > index) {
                rectsToDelete.append(rect)
            }
        }
        
        for rect in rectsToDelete {
            rect.runAction(SKAction.moveByX(0, y: rect.size.height + 2, duration: 0.25))
        }
        */
        if upperCellIndex + 11  < cellsCount() {
            cells[upperCellIndex + 11 ].runAction(SKAction.fadeInWithDuration(0.25))
        } else {
            if upperCellIndex > 0 {
                cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 2, duration: 0.25))
                cells[upperCellIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
                upperCellIndex--
            }
        }
    }
    
    static func appendCellWithMovingLayer() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            if (bottomActionCellShouldFadeOut()) {
                var rectsCount = 0
                for rect in repeatRectangles {
                    if rect.position.y < visibleCells().last!.position.y {
                        rectsCount++
                    }
                }
                let topCellIndex = cells.indexOf(visibleCells().last!)!
                let downCellsQuantity = repeatRectsCount() + cellsCount() - topCellIndex - 1
                for (var i = 0 ; i < downCellsQuantity ; i++) {
                    moveCellsLayerUp()
                }
                
            }
            else {
                let topRectIndex = repeatRectangles.indexOf(visibleRects().last!)!
                let topCellIndex = cells.indexOf(visibleCells().last!)!
                let downCellsQuantity = repeatRectsCount() + cellsCount() - topRectIndex - topCellIndex - 2
                for (var i = 0 ; i < downCellsQuantity ; i++) {
                    moveCellsLayerUp()
                }
            }
        })
    }
    
    
    static func moveCellsLayerToTop() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            while (true) {
                moveCellsLayerUp()
                if (cells.last! == visibleCells().last!) {
                    break
                }
            }
        })
    }
    
    static func moveCellsLayerUp() {   //move cells layer when adding a new cell
        if canMoveCellsLayerUp() {
            cellsLayer.runAction(SKAction.moveByX(0, y: actionCellSize.height + 2, duration: 0.25))
            if (topActionCellShouldFadeOut()) {
                if (bottomActionCellShouldFadeOut() && visibleCells().last?.bottomRect != nil) {
                    let rect = visibleCells().last?.bottomRect
                    rect?.runAction(SKAction.fadeInWithDuration(0.25))
                }
                else {
                    let cellIndex = cells.indexOf(visibleCells().last!)! + 1
                    if (cellIndex < cells.count) {
                        cells[cellIndex].runAction(SKAction.fadeInWithDuration(0.25))
                    }
                }
                visibleCells().first!.runAction(SKAction.fadeOutWithDuration(0.25))
            }
            else {
                if (bottomActionCellShouldFadeOut() && visibleCells().last?.bottomRect != nil) {
                    let rect = visibleCells().last?.bottomRect
                    rect?.runAction(SKAction.fadeInWithDuration(0.25))
                }
                else {
                    let cellIndex = cells.indexOf(visibleCells().last!)! + 1
                    if (cellIndex < cells.count) {
                        cells[cellIndex].runAction(SKAction.fadeInWithDuration(0.25))
                    }
                }
                visibleRects().first!.runAction(SKAction.fadeOutWithDuration(0.25))
            }
           /* cells[upperCellIndex - visibleRects().count].runAction(SKAction.fadeOutWithDuration(0.25))
            cells[upperCellIndex - visibleRects().count + 11].runAction(SKAction.fadeInWithDuration(0.25))
            upperCellIndex++*/
        }
    }
    
    static func moveCellsLayerDown() {   //move layer when
        if (visibleCells().first! != cells.first! || (visibleRects() != [] && visibleRects().first! != repeatRectangles.first!)) {
            cellsLayer.runAction(SKAction.moveByX(0, y: -actionCellSize.height - 2, duration: 0.25))
            if (topActionCellShouldFadeIn()) {
                let topCellIndex = cells.indexOf(visibleCells().first!)!
                cells[topCellIndex - 1].runAction(SKAction.fadeInWithDuration(0.25))
            }
            else {
                let topCellIndex = cells.indexOf(visibleCells().first!)!
                cells[topCellIndex].topRect!.runAction(SKAction.fadeInWithDuration(0.25))
            }
            if (bottomActionCellShouldFadeOut()) {
                visibleCells().last!.runAction(SKAction.fadeOutWithDuration(0.25))
            }
            else {
                visibleRects().last!.runAction(SKAction.fadeOutWithDuration(0.25))
            }
        }
    }
    
    static func canMoveCellsLayerUp() -> Bool {
        return visibleRects().count + visibleCells().count - 11 > 0
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
                action = SKAction.moveByX(61, y: -actionCellSize.height , duration: 0.25)
                cell.runAction(action)
            }
            else {
                cell.runAction(SKAction.moveByX(0, y: -actionCellSize.height, duration: 0.25))
            }
        }
        for rect in repeatRectangles {
            if (rect.position.y < cells[firstSelectedIndex].position.y) {
                rect.runAction(SKAction.moveByX(0, y: -actionCellSize.height, duration: 0.25))
            }
        }

    }
    
    static func getRectIndexes() {
        for (var i = 0 ; i < repeatRectangles.count ; i++) {
            repeatRectangles[i].name = "\(i)"
        }
    }
    
    static func visibleRects() -> [LoopControlRepeatRect] {
        var mas : [LoopControlRepeatRect] = []
        for rect in repeatRectangles {
            if (rect.alpha == 1) {
                mas.append(rect)
            }
        }
        return mas
    }
    
    static func visibleCells() -> [ActionCell] {
        var vcells : [ActionCell] = []
        for cell in cells {
            if cell.alpha == 1 {
                vcells.append(cell)
            }
        }
        return vcells
    }
    
    static func topActionCellShouldFadeOut() -> Bool {
        if (visibleRects() == []) {
            return true
        }
        else {
            if (visibleCells().first?.position.y > visibleRects().first?.position.y) {
                return true
            }
            else {
                return false
            }
        }
        
    }
    
    static func bottomActionCellShouldFadeOut() -> Bool {
        if (visibleRects() == []) {
            return true
        }
        else {
            if (visibleCells().last?.position.y < visibleRects().last?.position.y) {
                return true
            }
            else {
                return false
            }
        }
    }
    
    static func topActionCellShouldFadeIn() -> Bool {
        if (repeatRectangles == []) {
            return true
        }
        else {
            if (visibleRects() == []) {
                let firstCellIndex = cells.indexOf(visibleCells().first!)!
                if cells[firstCellIndex].topRect != nil {
                    return false
                }
                else {
                    return true
                }
            }
            else {
                let firstCellIndex = cells.indexOf(visibleCells().first!)!
                let firstRectIndex = repeatRectangles.indexOf(visibleRects().first!)!
                if (cells[firstCellIndex].position.y > repeatRectangles[firstRectIndex].position.y) {
                    return true
                }
                else {
                    return false
                }
            }
            
        }
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
