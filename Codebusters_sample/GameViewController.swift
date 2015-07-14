//
//  GameViewController.swift
//  Codebusters_sample
//
//  Created by Alexander on 28.03.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = /*LevelScene(size: CGSize(width: 2048, height: 1536))*/ MenuScene() /*LevelScene.level(0)*/
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            skView.showsPhysics = true
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
