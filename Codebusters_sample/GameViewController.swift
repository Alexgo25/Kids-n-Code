//
//  GameViewController.swift
//  Codebusters_sample
//
//  Created by Alexander on 28.03.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import SpriteKit
import Google
import GameKit

var sceneManager: SceneManager!

class GameViewController: UIViewController , UINavigationControllerDelegate , GKGameCenterControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            let skView = self.view as! SKView
            sceneManager = SceneManager(view: skView)
             sceneManager.presentScene(.Menu)
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            //skView.showsPhysics = true

        authGameCenter()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAds", name: kShowAdsNotificationKey, object: NotificationZombie.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLeaderboard", name: kShowGameCenterLeaderboard, object: NotificationZombie.sharedInstance)

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
    
    func authGameCenter() {
        let player = GKLocalPlayer()
        player.authenticateHandler = {
            (vc : UIViewController? , error : NSError?) -> Void in
            if (vc != nil) {
                self.presentViewController(vc!, animated: true, completion: nil)
            }
            else {
                if (GKLocalPlayer.localPlayer().authenticated) {
                    GKLocalPlayer.localPlayer().loadDefaultLeaderboardIdentifierWithCompletionHandler({
                        (str : String? , error : NSError?) -> Void in
                        if (error != nil) {
                            print(error?.localizedDescription)
                        }
                    })
                    
                }
            }
        }
    }
    
    func showLeaderboard() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            let gvc = GKGameCenterViewController()
            gvc.delegate = self
            gvc.gameCenterDelegate = self
            self.presentViewController(gvc, animated: true, completion: nil)
        })
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    

    
    
}
