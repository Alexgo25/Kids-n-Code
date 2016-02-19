//
//  LoopControlRepeatRect.swift
//  Kids'n'Code
//
//  Created by Alexander on 14/02/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

let LCRepeatLabelText = NSLocalizedString("REPEAT_LC_LABEL", comment: "repeat label")

protocol LCRepeatRectResponder {
    func moveRectUp()
    func moveRectDown()
}

class LoopControlRepeatRect : SKSpriteNode , ActionCellResponder {
    
    var repeatCells : [ActionCell] = []

    
    init (actionCell : ActionCell , numberOfRepeats : Int) {
        let texture = SKTexture(imageNamed: "repeatRect")
        super.init(texture: texture, color: UIColor.clearColor(), size: CGSize(width: texture.size().width , height: 66.0))
        self.position = CGPoint(x: actionCell.position.x + 30, y: actionCell.position.y)
        self.zPosition = 2002
        let text = LCRepeatLabelText + String(numberOfRepeats)
        let label = createLabel(text, fontColor: UIColor.whiteColor(), fontSize: 23, position: CGPoint(x: 0, y: 0))
        addChild(label)
        actionCell.delegate = self
        actionCell.repeatRect = self
        ActionCell.repeatRectangles.append(self)
    }
    
    func changeCell(actionCell : ActionCell) {
        actionCell.repeatRect = self
        actionCell.delegate = self
    }
    
    func actionCellShouldMoveUp() {
        self.runAction(SKAction.moveByX(0, y: self.size.height + 2, duration: 0.25))
    }
    
    func actionCellShouldMoveDown() {
        self.runAction(SKAction.moveByX(0, y: -self.size.height , duration: 0.25))
    }
    
    func actionCellShouldAppear() {
        self.runAction(SKAction.fadeInWithDuration(0.25))
    }
    
    func actionCellShouldDisappear() {
        self.runAction(SKAction.fadeOutWithDuration(0.25))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
