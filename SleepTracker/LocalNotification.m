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

- (void)setLocalNotificationWithMessage:(NSString *)message fireDate:(NSDate *)fireDate repeatOrNot:(BOOL)repeat sound:(NSString *)sound
                               setValue:(id)value forKey:(NSString *)key
                               category:(NSString *)category
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // 如果 fireDate 比現在時間還要早的話，把 fireDate 往後調 24 小時
    while ([[fireDate earlierDate:[NSDate date]] isEqualToDate:fireDate]) fireDate = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:fireDate];
    localNotification.fireDate = fireDate;
    
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.alertBody = message;
    localNotification.soundName = sound;  //@"UILocalNotificationDefaultSoundName"
    
    localNotification.repeatInterval = repeat ? NSCalendarUnitDay : 0 ;
    localNotification.userInfo = key ? [NSDictionary dictionaryWithObject:value forKey:key] : nil ;
    localNotification.category = category;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
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

#pragma mark - Init Notificatioin Setting

- (void)initLocalNotification
{
    UIMutableUserNotificationAction *remindAction = [self setActionWithIdentifier:@"later"
                                                                            title:@"稍後提醒"
                                                                   activationMode:UIUserNotificationActivationModeForeground
                                                                      destructive:NO authenticationRequired:NO];
    UIMutableUserNotificationAction *nightAction = [self setActionWithIdentifier:@"night"
                                                                           title:@"我要熬夜"
                                                                  activationMode:UIUserNotificationActivationModeForeground
                                                                     destructive:YES authenticationRequired:NO];
    UIMutableUserNotificationCategory *c = [self setCategoryWithAction:@[remindAction, nightAction] identifier:@"SleepNotification"];
    
    [self registratNotificationWithCategory:@[c]];
}

#pragma mark - Notificatioin Action

- (UIMutableUserNotificationAction *)setActionWithIdentifier:(NSString *)identifier
                                                       title:(NSString *)title
                                              activationMode:(UIUserNotificationActivationMode)activationMode
                                                 destructive:(BOOL)destructive
                                      authenticationRequired:(BOOL)authenticationRequired
{
    UIMutableUserNotificationAction *notificationAction = [[UIMutableUserNotificationAction alloc] init];
    notificationAction.identifier = identifier;
    notificationAction.title = title;
    notificationAction.activationMode = activationMode;
    notificationAction.destructive = destructive;
    notificationAction.authenticationRequired = authenticationRequired;
    
    return notificationAction;
}

#pragma mark - Notificatioin Category

- (UIMutableUserNotificationCategory *)setCategoryWithAction:(NSArray *)action identifier:(NSString *)identifier
{
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = identifier;
    [category setActions:action forContext:UIUserNotificationActionContextDefault];
    
    return category;
}

#pragma mark - Regist Notificatioin

- (void)registratNotificationWithCategory:(NSArray *)category
{
    NSSet *categories = [NSSet setWithArray:category];  //[NSSet setWithObjects:category, nil];
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
    UIUserNotificationSettings *setings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:setings];
}

@end
