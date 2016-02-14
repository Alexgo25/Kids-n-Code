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

class LoopControlRepeatRect : SKSpriteNode {
    
    var lowerCellIndex : Int!
    
    
    init (actionCell : ActionCell , numberOfRepeats : Int) {
        let texture = SKTexture(imageNamed: "repeatRect")
        super.init(texture: texture, color: UIColor.clearColor(), size: CGSize(width: 300, height: 63))
        self.position = CGPoint(x: actionCell.position.x + 30, y: actionCell.position.y)
        self.zPosition = 2002
        lowerCellIndex = ActionCell.cells.indexOf(actionCell)
        let text = LCRepeatLabelText + String(numberOfRepeats)
        let label = createLabel(text, fontColor: UIColor.whiteColor(), fontSize: 23, position: CGPoint(x: 0, y: 0))
        addChild(label)
        ActionCell.repeatRectangles.append(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
