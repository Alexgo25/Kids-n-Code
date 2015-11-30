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
        
            skView.presentScene(scene)
        dispatch_async(dispatch_get_main_queue(), {
            if (NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaultsNameKeys.kDeviceIDKey) == nil){
                let deviceid = String(stringInterpolationSegment: UIDevice.currentDevice().identifierForVendor)
                NSUserDefaults.standardUserDefaults().setObject(deviceid, forKey: "deviceID")
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: NSUserDefaultsNameKeys.kNeedUpdatesKey)
                print("game loaded for the first time")
            }
                
            else if (NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultsNameKeys.kNeedUpdatesKey) == true){
                AnalyticsCore.sharedAnalyticsCore.sendData()
                print("sending data")
            }
        })
        

        weak var audio = AudioPlayer.sharedInstance // Не убирать
        AudioPlayer.sharedInstance.playBackgroundMusic("backgroundMusic.mp3")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
