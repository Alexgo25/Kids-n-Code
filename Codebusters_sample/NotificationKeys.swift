//
//  NotificationKeys.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation

struct NotificationKeys {
    static let kRobotTookDetailNotificationKey = "RobotTookDetail"
    static let kRobotFinishedWithMistakeNotificationKey = "RobotFinishedWithMistake"
    static let kNodeTouchNotificationKey = "NodeTouch"
    static let kPauseQuitNotificationKey = "PauseQuit"
    static let kApplicationWillTerminateKey = "TerminateQuit"

}


class NotificationZombie {
    static let sharedInstance = NotificationZombie()
}
