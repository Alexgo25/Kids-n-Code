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
        let scene = MenuScene()
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            //skView.showsPhysics = true
            scene.scaleMode = .AspectFill
            AnalyticsCore.sharedAnalyticsCore.sendData()
            skView.presentScene(scene)
        if (NSUserDefaults.standardUserDefaults().objectForKey("deviceID") == nil){
            let deviceid = String(stringInterpolationSegment: UIDevice.currentDevice().identifierForVendor)
            NSUserDefaults.standardUserDefaults().setObject(deviceid, forKey: "deviceID")
        }
        
                GameProgress.sharedInstance.getSettings()
            AudioPlayer.sharedInstance.playBackgroundMusic("backgroundMusic.mp3")
        }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
