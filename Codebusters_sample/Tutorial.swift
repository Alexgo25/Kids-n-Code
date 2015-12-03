//
//  Tutorial.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 28.10.15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import SpriteKit

public class Tutorial: SKSpriteNode {
    private var firstSlide: Int
    private var currentSlideIndex: Int = 0
    private var lastSlide: Int
    private let ok = GameButton(type: .Ok)
    private var images: [SKSpriteNode] = []
    
    init(tutorialNumber: Int) {
        switch tutorialNumber {
        case 1:
            firstSlide = 0
            lastSlide = 5
        case 2:
            firstSlide = 6
            lastSlide = 7
        case 3:
            firstSlide = 8
            lastSlide = 8
        default:
            firstSlide = 0
            lastSlide = 8
        }
        
        for var i = firstSlide; i <= lastSlide; i++ {
            images.append(SKSpriteNode(imageNamed: "Tutorial_\(i)"))
            images[i - firstSlide].anchorPoint = CGPointZero
            images[i - firstSlide].position = CGPoint(x: CGFloat(i - firstSlide) * images[0].size.width, y: 0)
            images[i - firstSlide].zPosition = -1
        }
        
        super.init(texture: nil, color: SKColor.clearColor(), size: CGSize())
        zPosition = 3000
        
        addChild(ok)
        
        anchorPoint = CGPointZero
        
        show()
    }
    
    private func show() {
        alpha = 0
        addChild(images[currentSlideIndex])
       
        if currentSlideIndex + 1 < lastSlide - firstSlide {
            addChild(images[currentSlideIndex + 1])
        }
        
        runAction(SKAction.fadeInWithDuration(0.4))
    }
    
    func showNextSlide(direction: Direction) {
        let move = SKAction.moveByX(images[currentSlideIndex].size.width * CGFloat(direction.rawValue), y: 0, duration: 0.3)
        runAction(move, completion: {
            if self.currentSlideIndex + direction.rawValue >= 0 && self.currentSlideIndex + direction.rawValue <= self.lastSlide - self.firstSlide {
                self.images[self.currentSlideIndex + direction.rawValue].removeFromParent()
            }
            
            if self.currentSlideIndex - direction.rawValue <= self.lastSlide - self.firstSlide && self.currentSlideIndex - direction.rawValue >= 0 {
                self.currentSlideIndex -= direction.rawValue
                if self.currentSlideIndex > 0 && self.currentSlideIndex < self.lastSlide - self.firstSlide {
                    self.addChild(self.images[self.currentSlideIndex - direction.rawValue])
                }
            } else {
                TouchesAnalytics.sharedInstance.appendTouch("TutorialSkipTouch")
                self.removeAllChildren()
                self.removeFromParent()
            }
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}