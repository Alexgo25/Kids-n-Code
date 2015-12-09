//
//  AppDelegate.swift
//  Codebusters_sample
//
//  Created by Alexander on 28.03.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        // TODO: Move this to where you establish a user session
        self.logUser()
        YMMYandexMetrica.activateWithApiKey("d9143aae-dc60-4dbe-b7e2-638f574bedc1")
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound , UIUserNotificationType.Badge , UIUserNotificationType.Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        if (TimerDelegate.sharedTimerDelegate.timerIsRunning()) {
            TouchesAnalytics.sharedInstance.appendTouch(kTerminateApplicationKey)
            NSNotificationCenter.defaultCenter().postNotificationName(kApplicationWillTerminateKey, object: NotificationZombie.sharedInstance)
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Registering device token")
        let stringToken = convertDeviceTokenToString(deviceToken)
        print(stringToken)
        NSUserDefaults.standardUserDefaults().setObject(stringToken, forKey: kDevicePushTokenKey)
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Error registering token")
        let stringToken = "null"
        NSUserDefaults.standardUserDefaults().setObject(stringToken, forKey: kDevicePushTokenKey)
        print(error.localizedDescription)
    }
    
    //Crashlytics
    
    private func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("alexgo25616@gmail.com")
    }
    private func convertDeviceTokenToString(deviceToken : NSData) ->String {
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(">", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "")
        return deviceTokenStr
        
    }

}