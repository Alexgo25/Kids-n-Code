//
//  AnalyticsCore.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import UIKit

let urlstr = "http://kidsncode.com/php/analytics.php"
let tempAnalyticsUrl = "http://kidsncode.com/php/simplepush/sendpush.php?push=1"



class AnalyticsCore : NSObject{
    

    
    class var sharedAnalyticsCore : AnalyticsCore{
        struct Singleton {
            static let core = AnalyticsCore()
        }
        return Singleton.core
    }
    

    
    override init() {
        super.init()
    }
    

    
    
    func returnTouchesAsArray(touches : NSSet)->[String!] {
        let arr  = touches.allObjects as! [Touch!]
        var strarr : [String!] = []
        for obj in arr {
            strarr.append(obj.touchedNode)
        }
        return strarr
    }
    func returnActionsAsArray(actions : NSSet) -> [String!] {
        let arr = actions.allObjects as! [Action!]
        var strarr : [String!] = []
        for obj in arr {
            strarr.append(obj.actionType)
        }
        return strarr
    }
    func returnLevelAsNSDictionary(level : Level)->NSDictionary {
        let dict : NSDictionary = ["levelNumber" : level.levelNumber,
            "levelPackNumber" : level.levelPackNumber,
            "finished" : level.finished,
            "time" : level.time ,
            "date1" : stringFromNSDate(level.date),
            "actions" : returnActionsAsArray(level.actions),
            "touches" : returnTouchesAsArray(level.touches),
        ]
        return dict
    }
    
    func getFinalJSONData(levels : [Level!])->NSDictionary{
        let arr = NSMutableArray()
        for level in levels {
            arr.addObject(returnLevelAsNSDictionary(level))
        }
        let deviceid = NSUserDefaults.standardUserDefaults().objectForKey("deviceID") as! String
        let dict = ["device" : deviceid,
            "levels" : arr]
        return dict
    }
    
    
    func stringFromNSDate(date : NSDate)->String{
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let str = dateFormatter.stringFromDate(date)
        return str
    }
    
    func sendDevicePushToken(deviceToken : String) {
        let dict = ["devicePushToken" : deviceToken]
    }
    
    func sendData() {
        //try print(getFinalJSONData(CoreDataAdapter.sharedAdapter.getLevels()))
        let URLSTR = urlstr
        let url = NSURL(string: URLSTR)
        let request = NSMutableURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(getFinalJSONData(CoreDataAdapter.sharedAdapter.getLevels()), options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch _ {
            print("error")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if (response != nil) {
                print("Response: \(response)")
                //deleting coredata
                do {
                    try CoreDataAdapter.sharedAdapter.deleteAllLevels()
                }
                catch _ {
                    print("Error deleting coredata")
                }
            }
            if (error == nil) {
                let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
            }
            
        })
        task.resume()
        
    }
}

class TouchesAnalytics {
    private var touchesToRecord : [String!] = []
    static let sharedInstance = TouchesAnalytics()
    
    func appendTouch(touch : String) {
        touchesToRecord.append(touch)
        print(touch)
    }
    
    func resetTouches() {
        touchesToRecord = []
        print("Reset all touches")
    }
    func getNodes()->[String!] {
        return touchesToRecord
    }
}
