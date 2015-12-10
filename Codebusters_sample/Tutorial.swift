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
    private let ok: GameButton
    private var images: [SKSpriteNode] = []
    private let slides: SKSpriteNode
    private var slider: [SKSpriteNode] = []
    private var sliderNode: SKSpriteNode
    
    
    init(tutorialNumber: Int) {
        slides = SKSpriteNode(texture: nil, color: UIColor.clearColor(), size: CGSize())
        slides.zPosition = -2
        
        sliderNode = SKSpriteNode(texture: nil, color: UIColor.clearColor(), size: CGSize())
        sliderNode.position = CGPoint(x: 940, y: 80)

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
            let number = -((firstSlide + lastSlide)/2 - (i - firstSlide))
            let sliderElement = SKSpriteNode(imageNamed: "Slider_NonActive")
            sliderElement.position = CGPoint(x: number * 60, y: 0)
            slider.append(sliderElement)
            sliderNode.addChild(sliderElement)
        }
        
        ok = GameButton(type: .Ok)
        ok.zPosition = 0
        
        super.init(texture: nil, color: SKColor.clearColor(), size: CGSize())
        zPosition = 3000
        
        addChild(ok)
        addChild(slides)
        addChild(sliderNode)
        
        slider[0].texture = SKTexture(imageNamed: "Slider_Active")
        
        anchorPoint = CGPointZero
        
        show()
    }
    
    private func show() {
        alpha = 0
        slides.addChild(images[currentSlideIndex])
       
        if currentSlideIndex + 1 < lastSlide - firstSlide {
            slides.addChild(images[currentSlideIndex + 1])
        }
        
        runAction(SKAction.fadeInWithDuration(0.4))
    }
    
    private func hide() {
        runAction(SKAction.fadeOutWithDuration(0.3), completion: {
            TouchesAnalytics.sharedInstance.appendTouch("TutorialSkipTouch")
            self.removeAllChildren()
            self.removeFromParent()
        })
    }
    
    func showNextSlide(direction: Direction) {
        let move = SKAction.moveByX(images[currentSlideIndex].size.width * CGFloat(direction.rawValue), y: 0, duration: 0.3)
        slides.runAction(move, completion: {
            self.slider[self.currentSlideIndex].texture = SKTexture(imageNamed: "Slider_NonActive")
            if self.currentSlideIndex + direction.rawValue >= 0 && self.currentSlideIndex + direction.rawValue <= self.lastSlide - self.firstSlide {
                self.images[self.currentSlideIndex + direction.rawValue].removeFromParent()
            }
            
            if self.currentSlideIndex - direction.rawValue <= self.lastSlide - self.firstSlide && self.currentSlideIndex - direction.rawValue >= 0 {
                self.slider[self.currentSlideIndex - direction.rawValue].texture = SKTexture(imageNamed: "Slider_Active")
                self.currentSlideIndex -= direction.rawValue
                if self.currentSlideIndex > 0 && self.currentSlideIndex < self.lastSlide - self.firstSlide {
                    self.slides.addChild(self.images[self.currentSlideIndex - direction.rawValue])
                }
            } else {
                self.hide()
            }
        })
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            if nodeAtPoint(touchLocation) == ok {
                self.hide()
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}