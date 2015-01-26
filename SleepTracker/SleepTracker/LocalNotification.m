//
//  LocalNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "LocalNotification.h"

#import <UIKit/UIKit.h>

@implementation LocalNotification

- (void)setLocalNotificationWithMessage:(NSString *)message fireDate:(NSDate *)fireDate repeatOrNot:(BOOL)repeat Sound:(NSString *)sound
                               setValue:(id)value forKey:(NSString *)key
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
