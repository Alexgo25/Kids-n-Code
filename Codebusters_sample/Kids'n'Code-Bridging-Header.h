//
//  Kids'n'Code-Bridging-Header.h
//  Kids'n'Code
//
//  Created by Alexander on 03/12/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

#ifndef Kids_n_Code_Bridging_Header_h
#define Kids_n_Code_Bridging_Header_h

#import <Google/Analytics.h>
#import <Mixpanel/Mixpanel.h>
#import "Flurry.h"


//push token
#define kDevicePushTokenKey "pushToken"

//notification keys
#define kRobotTookDetailNotificationKey "RobotTookDetail"
#define kRobotFinishedWithMistakeNotificationKey "RobotFinishedWithMistake"
#define kNodeTouchNotificationKey "NodeTouch"
#define kPauseQuitNotificationKey "PauseQuit"
#define kApplicationWillTerminateKey "TerminateQuit"
#define kIfLastLevelInPack "LastLevelInPack"
#define kShowAdsNotificationKey "showAdsAtTheEnd"
//action keys
#define kTerminateApplicationKey "terminateApplication"
//name keys
#define kDeviceIDKey "deviceID"
#define kNeedUpdatesKey "needUpdates"






#endif /* Kids_n_Code_Bridging_Header_h */
