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
let LCMiddleRectSize = CGSize(width: 154, height: 63)

//positions for all elements
let LCFullRectInitialPosition = CGPoint(x: 2163, y: 319)
// for fullrectposition - normalX = 1748 but initial = 2148 to perform animation -
//moveByX : 400
let LCNumberOfRepeatsLabelPosition = CGPoint(x: 0, y: -14)
let LCMiddleRectPosition = CGPoint(x: 199, y: 57)
let LCTopLabelPosition = CGPoint(x: 0, y: 92)
//text for top label
let kLCTopLabelText = NSLocalizedString("NUMBER_OF_REPEATS_LABEL", comment: "Top label text")

class LoopControlFullRect : SKSpriteNode , LCPolygonResponder  {
    
    private let leftPolygon = LoopControlPolygon(polygonType: .Left)
    private let rightPolygon = LoopControlPolygon(polygonType: .Right)
    private var numberOfRepeatsLabel : SKLabelNode!
    private var topLabel : SKLabelNode!
    
    var numberOfRepeats = 2 {
        didSet {
            updateLabel()
        }
    }
    
    init() {
        let texture = SKTexture(imageNamed: "LCFullRect")
        let size = CGSize(width: 466, height: 228)
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        addChild(leftPolygon)
        addChild(rightPolygon)
        zPosition = 1002
        position = LCFullRectInitialPosition
        addLabels()
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateLabel() {
        numberOfRepeatsLabel.text = String(numberOfRepeats)
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
    
    func addLabels() {
        numberOfRepeatsLabel = createLabel(String(numberOfRepeats), fontColor: UIColor.blackColor(), fontSize: 76, position: LCNumberOfRepeatsLabelPosition)
        topLabel = createLabel(kLCTopLabelText, fontColor: UIColor.blackColor(), fontSize: 28.56, position: LCTopLabelPosition)
        addChild(topLabel)
        addChild(numberOfRepeatsLabel)
    }
    
    func leftPolygonTap() {
        print("left tap")
        if (numberOfRepeats > 2) {
            numberOfRepeats--
        }
    }
    
    func rightPolygonTap() {
        print("right tap")
        numberOfRepeats++
    }
    
}