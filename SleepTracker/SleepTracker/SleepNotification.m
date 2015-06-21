//
//  SleepNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/6/14.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SleepNotification.h"

#import "IntelligentNotification.h"
#import "CustomNotification-Model.h"

@implementation SleepNotification

- (void)goToBed
{
    [self cancelAllLocalNotification];  //刪除所有還沒發出的通知
    [[[IntelligentNotification alloc] init] setRemindUserToRecordWakeUpTime];
}

- (void)wakeUp
{
    [self cancelAllLocalNotification];  //主要是要把提醒使用者輸入起床時間的通知刪除
    [[[IntelligentNotification alloc] init] setIntelligentNotification];
    [[[CustomNotification_Model alloc] init] setCustomNotificatioin];
}

- (void)resetSleepNotification
{
    [[[IntelligentNotification alloc] init] rescheduleIntelligentNotification];
    [[[CustomNotification_Model alloc] init] resetCustomNotification];
}

- (void)cancelAllLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
