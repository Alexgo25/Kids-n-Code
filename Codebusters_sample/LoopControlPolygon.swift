//
//  LoopControlPolygon.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/01/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

let LCLeftPolygonPosition = CGPoint(x: -150, y: 0)
let LCRightPolygonPosition = CGPoint(x: 150, y: 0)

enum LCPolygonType : String {
    case Right = "Right",
    Left = "Left"
    
    func getLCPolygonPosition()->CGPoint {
        switch self {
        case .Right :
            return LCRightPolygonPosition
        default :
            return LCLeftPolygonPosition
        }
    }
    
}

protocol LCPolygonResponder {
    func leftPolygonTap()
    func rightPolygonTap()
}

class LoopControlPolygon : SKSpriteNode {
    
    var delegate : LCPolygonResponder {
        guard let responder = parent as? LCPolygonResponder else { fatalError() }
        return responder
    }
    var type : LCPolygonType?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture!, color: color, size: size)
    }
    
    convenience init(polygonType : LCPolygonType) {
        let texture = SKTexture(imageNamed: "LCPolygon_\(polygonType.rawValue)")
        let color = UIColor.clearColor()
        let size = LCPolygonSize
        self.init(texture: texture, color: color, size: size)
        type = polygonType
        zPosition = 2003
        position = polygonType.getLCPolygonPosition()
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = parent else { fatalError() }
        
        return touches.contains { touch in
            let touchLocation = touch.locationInNode(scene)
            let touchedNode = scene.nodeAtPoint(touchLocation)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
    }

    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (containsTouches(touches)) {
            switch type! {
            case .Right :
                delegate.rightPolygonTap()
                super.touchesBegan(touches, withEvent: event)
            default :
                delegate.leftPolygonTap()
                super.touchesBegan(touches, withEvent: event)
            }
        }
        
    }
    
   
}
