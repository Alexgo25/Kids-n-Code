//
//  DetailCell.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 28.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import SpriteKit

enum DetailCellState: String {
    case NonActive,
    Active,
    Placed = ""
}

class DetailCell: SKSpriteNode {
    var cellState: DetailCellState
    var detailType: DetailType
    let index: Int
    
    init(detailType: DetailType, cellState: DetailCellState, index: Int) {
        let atlas = SKTextureAtlas(named: "Details")
        let texture = atlas.textureNamed("Detail_\(detailType)")
        self.cellState = cellState
        self.detailType = detailType
        self.index = index
        
        super.init(texture: nil, color: SKColor.clearColor(), size: texture.size())
        
        zPosition = 1003
        position = detailType.getDetailCellPosition()
        
        switch cellState {
        case .Active, .NonActive:
            let number = SKSpriteNode(imageNamed: cellState.rawValue)
            number.zPosition = -1002
            number.addChild(createLabel(String(index + 1), fontColor: SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), fontSize: 36, position: CGPointZero))
            addChild(number)
            if cellState == .Active {
                let light = SKSpriteNode(imageNamed: "activeLight")
                light.zPosition = -1003
                addChild(light)
            }
        case .Placed:
            self.texture = texture
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}