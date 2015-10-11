//
//  DetailCell.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 28.04.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

enum DetailCellState: String {
    case NonActive = "NonActive",
    Active = "Active",
    Placed = ""
}

class DetailCell: SKSpriteNode {

    private var cellState: DetailCellState
    private var detailType: DetailType
    private let atlas = SKTextureAtlas(named: "Details")
    
    init(detailType: DetailType, cellState: DetailCellState, name: String) {
       
        let texture = atlas.textureNamed("Detail_\(detailType.rawValue)")
        self.cellState = cellState
        self.detailType = detailType
        
        super.init(texture: nil, color: SKColor.clearColor(), size: texture.size())
        
        zPosition = 1003
        self.name = name
        position = getDetailCellPosition(detailType)
        
        switch cellState {
        case .Active:
            let number = SKSpriteNode(imageNamed: "active")
            number.zPosition = -1002
            number.addChild(createLabel(String(name.toInt()! + 1), SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), 36, CGPointZero))
            addChild(number)
        case .NonActive:
            let number = SKSpriteNode(imageNamed: "nonActive")
            number.zPosition = -1002
            number.addChild(createLabel(String(name.toInt()! + 1), SKColor(red: 255/255.0, green: 251/255.0, blue: 233/255.0, alpha: 1), 36, CGPointZero))
            addChild(number)
        case .Placed:
            self.texture = texture
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCellState() -> DetailCellState {
        return cellState
    }
    
    func getDetailType() -> DetailType {
        return detailType
    }
}