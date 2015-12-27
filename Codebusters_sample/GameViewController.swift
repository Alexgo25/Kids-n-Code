//
//  GameViewController.swift
//  Codebusters_sample
//
//  Created by Alexander on 28.03.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit

var sceneManager: SceneManager!

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        sceneManager = SceneManager(view: skView)
        sceneManager.presentScene(.Menu)
        
        //skView.showsPhysics = true
        //scene.scaleMode = .AspectFill
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("deviceID") == nil) {
            let deviceID = String(stringInterpolationSegment: UIDevice.currentDevice().identifierForVendor)
            NSUserDefaults.standardUserDefaults().setObject(deviceID, forKey: "deviceID")
        }
        AnalyticsCore.sharedAnalyticsCore.sendData()

        weak var audio = AudioPlayer.sharedInstance // Не убирать
        AudioPlayer.sharedInstance.playBackgroundMusic("backgroundMusic.mp3")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
