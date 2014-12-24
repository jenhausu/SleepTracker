//
//  SetLocalNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "SetLocalNotification.h"
#import <UIKit/UIKit.h>

@implementation SetLocalNotification

- (void)setLocalNotificationWithMessage:(NSString *)message fireDate:(NSDate *)fireDate repeatOrNot:(BOOL)repeat Sound:(NSString *)sound key:(NSString *)key forValue:(id)value
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = message;
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = sound;
    
    if (repeat) localNotification.repeatInterval = NSCalendarUnitDay;  //每天循環
    if (key) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:value forKey:key];
        localNotification.userInfo = dic;
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
