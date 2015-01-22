//
//  IntelligentNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "IntelligentNotification.h"

#import "LocalNotification.h"
#import "SleepDataModel.h"
#import "SleepData.h"

@interface IntelligentNotification ()

@property (strong, nonatomic) NSArray *notification;
@property (strong, nonatomic) NSArray *message;
@property (strong, nonatomic) NSArray *fireTime;
@property (strong, nonatomic) NSDate *shouldGoToBedTime;

@property (strong, nonatomic) LocalNotification *localNotification;
@property (strong, nonatomic) SleepDataModel *sleepDataModel;
@property (strong, nonatomic) NSArray *fetchArray;
@property (strong, nonatomic) SleepData *sleepData;

@end

@implementation IntelligentNotification

@synthesize notification, message, fireTime, shouldGoToBedTime, fetchArray;

#pragma mark - Lazy initialization

- (LocalNotification *)localNotification
{
    if (!_localNotification) {
        _localNotification = [[LocalNotification alloc] init];
    }
    return _localNotification;
}

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    return _sleepDataModel;
}

#pragma mark - Decide

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
    [self deleteAllIntelligentNotification];
    
    [self decideMessage];
    [self decideFireDate];
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    
    for (NSInteger i = 0 ; i < [notification count] ; i++ ) {
        if ([userPreferences boolForKey:notification[i]]) {
            [self.localNotification setLocalNotificationWithMessage:message[i]
                                                           fireDate:fireTime[i]
                                                        repeatOrNot:YES
                                                              Sound:@"UILocalNotificationDefaultSoundName"
                                                                key:nil forValue:nil];
        }
    }
}

#pragma mark - Delete

- (void)deleteAllIntelligentNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
