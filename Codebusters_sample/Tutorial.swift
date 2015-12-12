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
        sliderNode.zPosition = 1
        
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
            //images[i - firstSlide].position = CGPoint(x: CGFloat(i - firstSlide) * images[0].size.width, y: 0)
            let number = -((lastSlide - firstSlide)/2 - (i - firstSlide))
            let sliderElement = SKSpriteNode(imageNamed: "Slider_NonActive")
            sliderElement.position = CGPoint(x: number * 60, y: 0)
            sliderElement.name = "\(i - firstSlide)"
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
        userInteractionEnabled = true
        
        show()
    }
    
    private func show() {
        alpha = 0
        slides.addChild(images[currentSlideIndex])
       
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
        if currentSlideIndex == 0 && direction == .ToRight {
            return
        }
        
        showSlide(currentSlideIndex - direction.rawValue)
    }
    
    func showSlide(number: Int) {
        let direction = (number < currentSlideIndex) ? Direction.ToRight : Direction.ToLeft
            
        if number <= lastSlide - firstSlide && number >= 0 {
            slides.addChild(images[number])
            images[number].position = CGPoint(x: -slides.position.x - 2048 * CGFloat(direction.rawValue), y: slides.position.y)
        } else {
            let moveSlides = SKAction.moveByX(2048 * CGFloat(direction.rawValue), y: 0, duration: 0.3)
            slides.runAction(moveSlides, completion: {
                self.hide()
                return
            })
        }
        
        let moveSlides = SKAction.moveByX(2048 * CGFloat(direction.rawValue), y: 0, duration: 0.3)
        slides.runAction(moveSlides, completion: {
            self.images[self.currentSlideIndex].removeFromParent()
            self.slider[self.currentSlideIndex].texture = SKTexture(imageNamed: "Slider_NonActive")
            if number <= self.lastSlide - self.firstSlide && number >= 0 {
                self.currentSlideIndex = number
                self.slider[self.currentSlideIndex].texture = SKTexture(imageNamed: "Slider_Active")
            }
        })
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            if nodeAtPoint(touchLocation) == ok {
                self.hide()
                return
            }
            
            if let name = nodeAtPoint(touchLocation).name {
                if let number = Int(name) {
                    showSlide(number)
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}