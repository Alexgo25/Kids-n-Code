//
//  LoopControlPolygon.swift
//  Kids'n'Code
//
//  Created by Alexander on 28/01/16.
//  Copyright © 2016 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

let LCLeftPolygonPosition = CGPoint(x: 53, y: 66)
let LCRightPolygonPosition = CGPoint(x: 343, y: 66)

enum LCPolygonType : String {
    case Right = "Right",
    Left = "Left"
    
    func getLCPolygonPosition()->CGPoint {
        switch self {
        case .Right :
            return LCLeftPolygonPosition
        default :
            return LCRightPolygonPosition
        }
    }
    
}

protocol LCPolygonResponder {
    func leftPolygonTap()
    func rightPolygonTap()
}

class LoopControlPolygon : SKSpriteNode {
    
    var delegate : LCPolygonResponder!
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch type! {
        case .Right :
            delegate.leftPolygonTap()
        default :
            delegate.rightPolygonTap()
        }
    }
    
    
    
    
}
