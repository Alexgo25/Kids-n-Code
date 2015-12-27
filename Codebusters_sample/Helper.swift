//
//  Helper.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 06.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

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