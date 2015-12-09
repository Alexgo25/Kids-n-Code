//
//  GameViewController.swift
//  Codebusters_sample
//
//  Created by Alexander on 28.03.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds



class GameViewController: UIViewController {
    
    var interstitial: GADInterstitial!
    
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
        //Ad mob setup
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAds", name: kShowAdsNotificationKey, object: NotificationZombie.sharedInstance)
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-5211168829941199/5039541065")
        let request = GADRequest()
        request.tagForChildDirectedTreatment(true)
        //request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        interstitial.loadRequest(GADRequest())
        //
        //Sending data to server
        dispatch_async(dispatch_get_main_queue(), {
            if (NSUserDefaults.standardUserDefaults().objectForKey(kDeviceIDKey) == nil){
                let deviceid = String(stringInterpolationSegment: UIDevice.currentDevice().identifierForVendor)
                NSUserDefaults.standardUserDefaults().setObject(deviceid, forKey: "deviceID")
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kNeedUpdatesKey)
                print("game loaded for the first time")
            }
                
            else if (NSUserDefaults.standardUserDefaults().boolForKey(kNeedUpdatesKey) == true){
                AnalyticsCore.sharedAnalyticsCore.sendData()
                print("sending data")
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kNeedUpdatesKey)
            }
        })
        //
        //
        weak var audio = AudioPlayer.sharedInstance // Не убирать
        AudioPlayer.sharedInstance.playBackgroundMusic("backgroundMusic.mp3")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showAds(){
        if interstitial.isReady {
            interstitial.presentFromRootViewController(self)
        }
    }
    
    
}
