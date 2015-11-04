//
//  TimerDelegate.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation

class TimerDelegate : NSObject {
    
    class var sharedTimerDelegate : TimerDelegate {
        struct Singleton {
            static let sharedTimer = TimerDelegate()
        }
        return Singleton.sharedTimer
    }
    
    private var isRunning = false
    private var date = NSDate()
    
    override init(){
        super.init()
    }
    
    func startTimer() {
        if (isRunning) {
            print("Timer is already running!")
        }
        else {
            print("Starting Timer!")
            isRunning = true
            date = NSDate()
        }
    }
    
    func stopAndReturnTime() -> Double {
        let dateDiff = NSDate()
        let time = dateDiff.timeIntervalSinceDate(date)
        print(time)
        isRunning = false
        return time
    }
    
    
    
    
}
