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
    private var firstSlide = 0
    private var currentSlide = SKSpriteNode()
    private var currentSlideIndex = 0
    private var numberOfSlides = 0
    private var currentTutorial = 0
    private let ok = GameButton(type: .Ok)
    
    static var sharedInstance = Tutorial()

    init() {
        super.init(texture: nil, color: SKColor.clearColor(), size: CGSize())
        zPosition = 2000
        userInteractionEnabled = true
        currentSlide.zPosition = -1
    }
    
    public func showFullTutorial() {
        currentTutorial = 0
        numberOfSlides = 7
        show()
    }
    
    public func showFirstPart() {
        currentTutorial = 1
        numberOfSlides = 4
        show()
    }
    
    public func showSecondPart() {
        currentTutorial = 2
        numberOfSlides = 1
        show()
    }
    
    public func showThirdPart() {
        currentTutorial = 3
        numberOfSlides = 0
        show()
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = nodeAtPoint(touchLocation)
            switch node {
            case ok:
                TouchesAnalytics.sharedInstance.appendTouch("TutorialSkipTouch")
                hide()
            default:
              TouchesAnalytics.sharedInstance.appendTouch("TutorialSlideTouch")
                if currentSlideIndex < numberOfSlides {
                    showNextSlide()
                    
                } else {
                    hide()
                }
            }
        }
    }
    
    private func show() {
        addChild(ok)
        alpha = 0
        currentSlideIndex = 0
        firstSlide = 0
        currentSlide = SKSpriteNode(imageNamed: "Tutorial\(currentTutorial)_\(firstSlide)")
        currentSlide.anchorPoint = CGPointZero
        currentSlide.position = CGPointZero
        addChild(currentSlide)
        runAction(SKAction.fadeInWithDuration(0.4))
    }
    
    private func hide() {
        runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.2), SKAction.runBlock() { self.removeAllChildren(); self.position = CGPointZero }, SKAction.removeFromParent()]))
    }
    
    public func showNextSlide() {
        let slide = SKSpriteNode(imageNamed: "Tutorial\(currentTutorial)_\(currentSlideIndex + 1)")
        slide.anchorPoint = CGPointZero

        if let scene = self.scene {
            addChild(slide)
            currentSlideIndex++
            slide.position = CGPoint(x: scene.size.width, y: 0)
            currentSlide.runAction(SKAction.sequence([SKAction.moveByX(-scene.size.width, y: 0, duration: 0.4), SKAction.removeFromParent()]))
            slide.runAction(SKAction.sequence([SKAction.moveByX(-scene.size.width, y: 0, duration: 0.4), SKAction.runBlock() { self.currentSlide = slide }]))
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}