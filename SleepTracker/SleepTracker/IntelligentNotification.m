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
#import "Statistic.h"

@interface IntelligentNotification ()

@property (nonatomic) SleepData *sleepData;
@property (nonatomic) Statistic *statistic;

@end

@implementation IntelligentNotification

#pragma mark - Lazy initialization

- (Statistic *)statistic
{
    if (!_statistic) {
        _statistic = [[Statistic alloc] init];
    }
    
    return _statistic;
}

#pragma mark - Decide

- (NSDate *)decideShouldGoToBedTime
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSInteger shouldGoToSleepTime = [userPreferences integerForKey:@"ShouldGoToSleepTime"];
    
    switch (shouldGoToSleepTime) {
        case 0: {  //平均上床時間
            NSInteger averageGoToSleepTimeInSecond = [[[self.statistic showGoToBedTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
            [components setHour:averageGoToSleepTimeInSecond / 3600];
            [components setMinute:((averageGoToSleepTimeInSecond / 60) % 60)];
        }
            break;
        case 1: {  //平均起床時間
            NSInteger averageWakeUpTimeInSecond = [[[self.statistic showWakeUpTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
            if (((averageWakeUpTimeInSecond / 3600) - 8) > 0) {
                [components setHour:averageWakeUpTimeInSecond / 3600 - 8];
                [components setMinute:((averageWakeUpTimeInSecond / 60) % 60)];
            } else {
                [components setHour:(averageWakeUpTimeInSecond / 3600) - 8 + 24];
                [components setMinute:60 - ((averageWakeUpTimeInSecond / 60) % 60)];
            }
        }
            break;
        case 2: {  //自訂
            NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
            NSDate *HopeToGoToBedTime = [userPreferences valueForKey:@"HopeToGoToBedTime"];
            NSDateComponents *dateComponents = [greCalendar components: NSCalendarUnitHour | NSCalendarUnitMinute fromDate:HopeToGoToBedTime];
            
            [components setHour:dateComponents.hour];
            [components setMinute:dateComponents.minute];
        }
        break;
    }
    
    return [greCalendar dateFromComponents:components];
}

- (NSArray *)decideNotificationTitle
{
    NSArray *notification = @[@"不要再吃宵夜", @"不要再看任何電子螢幕", @"建議此時去洗澡", @"超過午夜十二點", @"平均上床時間", @"醒來超過十六小時"];
    
    return notification;
}

- (NSArray *)decideMessage
{
    NSArray *message = @[@"建議你不要再吃東西，讓胃開始休息了。",
                         @"建議你不要再看任何電子螢幕了，讓眼睛開始休息。",
                         @"如果你想要在十一點時上床睡覺，建議你可以現在去沖個澡，這樣兩個小時後體溫開始下降，正好適合睡覺。",
                         @"已經過了午夜十二點了，趕快去睡覺吧。",
                         @"已經過了你平均上床的時間了，趕快上床休息吧。",
                         @"從你今天起床醒來到現在已經超過十六個小時了，建議你盡快去上床休息吧。"];
    
    return message;
}

- (NSArray *)decideFireDate
{
    NSArray *fetchDataArray = [[[SleepDataModel alloc] init] fetchSleepDataSortWithAscending:NO];
    
    NSArray *fireDate;
    NSDate *shouldGoToBedTime = [self decideShouldGoToBedTime];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    [components setHour:0];
    [components setMinute:0];
    NSDate *NULLDate = [calendar dateFromComponents:components];
    
    SleepData *sleepData;
    if (fetchDataArray.count > 0) {
        NSInteger const LATEST_DATA = 0;
        sleepData = fetchDataArray[LATEST_DATA];
    }
    
    if (fetchDataArray.count >= 2 || (fetchDataArray.count == 1 && sleepData.wakeUpTime > 0) ) {
        NSInteger averageGoToSleepTimeInSecond = [[[self.statistic showGoToBedTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
        [components setHour:averageGoToSleepTimeInSecond / 3600];
        [components setMinute:((averageGoToSleepTimeInSecond / 60) % 60)];
        NSDate *averageGoToSleepTime = [calendar dateFromComponents:components];
        
        //如果現在是睡眠狀態，把「醒來超過十六小時」的 fireDate 設為 00:00，雖然原本的方法也沒有出現錯誤，但我為了避免以後會出什麼問題，所以我就用這個判別式把出錯的可能給擋掉。
        if (sleepData.wakeUpTime) {
            fireDate = [[NSArray alloc] initWithObjects:
                        [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:shouldGoToBedTime],
                        NULLDate,
                        averageGoToSleepTime,
                        [NSDate dateWithTimeInterval:(60 * 60 * 16) sinceDate:sleepData.wakeUpTime], nil];
        } else {
            fireDate = [[NSArray alloc] initWithObjects:
                        [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:shouldGoToBedTime],
                        NULLDate,
                        averageGoToSleepTime,
                        NULLDate, nil];
        }
    } else {
        fireDate = [[NSArray alloc] initWithObjects:
                    [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:NULLDate],
                    [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:NULLDate],
                    [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:NULLDate],
                    NULLDate,
                    NULLDate,
                    NULLDate, nil];
    }
    
    return fireDate;
}

#pragma mark - Reschedule

- (void)rescheduleIntelligentNotification
{
    [self deleteAllIntelligentNotification];
    
    NSArray *notification = [self decideNotificationTitle];
    NSArray *Message = [self decideMessage];
    NSArray *fireDate = [self decideFireDate];
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    LocalNotification *localNotification = [[LocalNotification alloc] init];
    
    NSArray *fetchArray = [[[SleepDataModel alloc] init] fetchSleepDataSortWithAscending:NO];
    if (fetchArray.count) {  //判斷有沒有資料，有資料的話就可以知道現在的睡眠狀態
        if ([[userPreferences valueForKey:@"睡眠狀態"] isEqualToString:@"清醒"]) {
            for (NSInteger i = 0 ; i < [notification count] ; i++ ) {
                if ([userPreferences boolForKey:notification[i]]) {
                    [localNotification setLocalNotificationWithMessage:Message[i]
                                                              fireDate:fireDate[i]
                                                           repeatOrNot:YES
                                                                 Sound:@"UILocalNotificationDefaultSoundName"
                                                              setValue:@"IntelligentNotification" forKey:@"NotificationType"];
                }
            }
        }
    } else {
        //如果沒有資料，就一定是清醒狀態，要不讓起馬會有一筆只有上床時間的資料，所以不用檢查睡眠狀態。
        //要獨立分出來是因為在沒有資料時，如果想要設定睡前通知的時候會被 if (fetchArray.count) 這個判別是給過濾掉
        for (NSInteger i = 0 ; i < [notification count] ; i++ ) {
            if ([userPreferences boolForKey:notification[i]]) {
                [localNotification setLocalNotificationWithMessage:Message[i]
                                                          fireDate:fireDate[i]
                                                       repeatOrNot:YES
                                                             Sound:@"UILocalNotificationDefaultSoundName"
                                                          setValue:@"IntelligentNotification" forKey:@"NotificationType"];
            }
        }
    }
}

#pragma mark - Delete

- (void)deleteAllIntelligentNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    NSString *value;
    
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        
        userInfo = localNotification.userInfo;
        value = [userInfo objectForKey:@"NotificationType"];
        
        if ([value isEqualToString:@"IntelligentNotification"])
        {
            [application cancelLocalNotification:localNotification];
        }
    }
}

@end
