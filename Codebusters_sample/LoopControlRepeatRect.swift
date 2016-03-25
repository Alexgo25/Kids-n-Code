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
let LCRectColor = UIColor(red: 164.0, green: 77.0, blue: 185.0, alpha: 1.0)

protocol LCRepeatRectResponder {
    func moveRectUp()
    func moveRectDown()
}

enum LCRepeatRectState {
    case Normal ,
    ShouldAppearFromTop ,
    ShouldDisappearFromTop ,
    ShouldAppearFromBottom ,
    ShouldDisappearFromBottom
}

class LoopControlRepeatRect : SKSpriteNode {
    
    var repeatCells : [ActionCell] = []
    var state = LCRepeatRectState.Normal

    
    init (actionCell : ActionCell , numberOfRepeats : Int ) {
        let texture = SKTexture(imageNamed: "repeatRect")
        super.init(texture: texture, color: UIColor.clearColor(), size: CGSize(width: texture.size().width, height: 78.0))
        self.position = CGPoint(x: actionCell.position.x + 30, y: actionCell.position.y)
        self.zPosition = 2002
        let text = LCRepeatLabelText + String(numberOfRepeats)
        let label = createLabel(text, fontColor: UIColor.whiteColor(), fontSize: 23, position: CGPoint(x: 0, y: 0))
        addChild(label)
        ActionCell.repeatRectangles.append(self)
        self.position = CGPoint(x: actionCell.position.x + 30, y: actionCell.position.y)
        name = "\(ActionCell.repeatRectangles.count - 1)"
    }
    
    func deleteCell(actionCell : ActionCell) {
        let index = repeatCells.indexOf(actionCell)
        if (index != nil) {
            repeatCells.removeAtIndex(index!)
        }
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
