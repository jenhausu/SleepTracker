//
//  IntelligentNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "IntelligentNotification.h"

@implementation IntelligentNotification

- (NSDate *)decideShouldGoToBedTime
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:23];
    [components setMinute:0];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    NSDate *shouldGoToBedTime = [calendar dateFromComponents:components];

    
    return shouldGoToBedTime;
}

- (NSArray *)decideFireTime
{
    
    NSArray *array;

    return array;
}

- (void)rescheduleIntelligentNotification
{
    
}

#pragma mark - Delete

- (void)deleteAllIntelligentNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
