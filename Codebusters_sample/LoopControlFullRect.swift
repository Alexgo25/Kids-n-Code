//
//  LoopControlFullRect.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/01/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

//sizes for Full rect , polygons and middle rect
let LCFullRectSize = CGSize(width: 466, height: 228)
let LCPolygonSize = CGSize(width: 30, height: 34)
let LCMiddleRectSize = CGSize(width: 154, height: 33)

//positions for all elements
let LCFullRectInitialPosition = CGPoint(x: 2148, y: 351)
// for fullrectposition - normalX = 1748 but initial = 2148 to perform animation -
//moveByX : 400
let LCNumberOfRepeatsLabelPosition = CGPoint(x: 77, y: 66)
let LCMiddleRectPosition = CGPoint(x: 199, y: 57)

class LoopControlFullRect : SKSpriteNode , LCPolygonResponder {
    
    private let leftPolygon = LoopControlPolygon(polygonType: .Left)
    private let rightPolygon = LoopControlPolygon(polygonType: .Right)
    private let middleRect = SKSpriteNode(texture: SKTexture(imageNamed: "LCMiddleRect"), color: UIColor.clearColor(), size: LCMiddleRectSize)
    
    var numberOfRepeats = 2 {
        didSet {
            updateLabel()
        }
    }
    
    init() {
        let texture = SKTexture()
        let size = CGSize(width: 466, height: 228)
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        addChild(leftPolygon)
        addChild(rightPolygon)
        addChild(middleRect)
        leftPolygon.delegate = self
        rightPolygon.delegate = self
        zPosition = 1002
        position = LCFullRectInitialPosition
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func leftPolygonTap() {
        if (numberOfRepeats > 2) {
            numberOfRepeats--
        }
    }
    
    func rightPolygonTap() {
        numberOfRepeats++
    }
    
    func updateLabel() {
        
    }
    
    func appearInScene() {
        let appearAction = SKAction.moveByX(-400, y: 0, duration: 0.2)
        let actions = SKAction.group([appearAction , SKAction.fadeInWithDuration(0.2)])
        self.runAction(actions)
    }
    
    func disappear() {
        let disappearAction = SKAction.moveByX(400, y: 0, duration: 0.2)
        let actions = SKAction.group([disappearAction , SKAction.fadeOutWithDuration(0.2)])
        self.runAction(actions)
    }
    
}