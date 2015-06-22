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

#pragma mark - Set

- (void)setLocalNotificationWithMessage:(NSString *)message fireDate:(NSDate *)fireDate repeatOrNot:(BOOL)repeat Sound:(NSString *)sound
                               setValue:(id)value forKey:(NSString *)key
{
    [self checkIfAppGetUserPermission];
    
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.timeZone = [NSTimeZone localTimeZone];
    while ([[fireDate earlierDate:[NSDate date]] isEqualToDate:fireDate]) {   // 如果 fireDate 比現在時間還要早的話，把 fireDate 往後調 24 小時
        fireDate = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:fireDate];
    }
    localNotification.fireDate = fireDate;
    
    localNotification.alertBody = message;
    localNotification.soundName = sound;  //@"UILocalNotificationDefaultSoundName"
    
    if (repeat) localNotification.repeatInterval = NSCalendarUnitDay;  //每天循環
    
    if (key) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:value forKey:key];
        localNotification.userInfo = dic;
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)checkIfAppGetUserPermission
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge
                                                                                                              categories:nil]];
    }
}

#pragma mark - Fetch

- (id)fetchLocalNotificationWithParticularOneValue:(id)value forKey:(NSString *)key
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        userInfo = localNotification.userInfo;
        
        if ([[userInfo objectForKey:key] isEqualToString:value])
        {
            return localNotification;
        }
    }
    
    return nil;
}

- (NSMutableArray *)fetchLocalNotifictionWithParticularKindOfValue:(id)value forKey:(NSString *)key
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    
    NSMutableArray *returnArray;
    
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        userInfo = localNotification.userInfo;
        
        if ([[userInfo objectForKey:key] isEqualToString:value])
        {
            [returnArray addObject:localNotification];
        }
    }
    
    return returnArray;
}

#pragma mark - Cancel

- (void)cancelLocalNotificaionWithValue:(id)value foreKey:(NSString *)key
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        userInfo = localNotification.userInfo;
        
        if ([[userInfo objectForKey:key] isEqualToString:value])
        {
            [application cancelLocalNotification:localNotification];
        }
    }
}

- (void)cancelAllLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
