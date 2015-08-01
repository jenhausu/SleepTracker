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
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSDateComponents *currentDate = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];

    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSInteger shouldGoToSleepTime = [userPreferences integerForKey:@"ShouldGoToSleepTime"];
    
    [dateComponents setYear:currentDate.year];
    [dateComponents setMonth:currentDate.month];
    [dateComponents setDay:currentDate.day];
    
    switch (shouldGoToSleepTime) {
        case 0: {  //平均上床時間
            NSInteger averageGoToSleepTimeInSecond = [[[self.statistic showGoToBedTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
            if (averageGoToSleepTimeInSecond) {
                [dateComponents setHour:averageGoToSleepTimeInSecond / 3600];
                [dateComponents setMinute:((averageGoToSleepTimeInSecond / 60) % 60)];
            } else {
                [dateComponents setHour:23];
                [dateComponents setMinute:0];
            }
            
            break;
        }
        case 1: {  //平均起床時間
            NSInteger averageWakeUpTimeInSecond = [[[self.statistic showWakeUpTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
            if (averageWakeUpTimeInSecond) {
                dateComponents.hour = (((averageWakeUpTimeInSecond / 3600) - 8) >= 0) ? averageWakeUpTimeInSecond / 3600 - 8 : (averageWakeUpTimeInSecond / 3600) - 8 + 24 ;
                dateComponents.minute = ((averageWakeUpTimeInSecond / 60) % 60);
            } else {
                [dateComponents setHour:23];
                [dateComponents setMinute:0];
            }
            
            break;
        }
        case 2: {  //自訂
            NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
            NSDate *HopeToGoToBedTime = [userPreferences valueForKey:@"HopeToGoToBedTime"];
            NSDateComponents *hopeToGoToBedTime = [greCalendar components: NSCalendarUnitHour | NSCalendarUnitMinute fromDate:HopeToGoToBedTime];
            [dateComponents setHour:hopeToGoToBedTime.hour];
            [dateComponents setMinute:hopeToGoToBedTime.minute];
            
            break;
        }
    }
    
    return [greCalendar dateFromComponents:dateComponents];
}

- (NSArray *)decideNotificationTitle
{
    NSArray *notification = @[@"不要再吃宵夜", @"不要再看任何電子螢幕", @"建議此時去洗澡", @"平均上床時間", @"醒來超過十六小時"];
    
    return notification;
}

- (NSArray *)decideMessage
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"H:mm"];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"H"];
    
    NSString *bathMessage;
    
    if ([[dateFormatter2 stringFromDate:[self decideShouldGoToBedTime]] integerValue] < 12) {
        bathMessage = [NSString stringWithFormat:@"如果你想要在凌晨 %@ 上床睡覺，建議你可以現在去沖個澡，這樣兩個小時後體溫開始下降，正好適合睡覺。", [dateFormatter stringFromDate:[self decideShouldGoToBedTime]]];
    } else {
        bathMessage = [NSString stringWithFormat:@"如果你想要在晚上 %@ 時上床睡覺，建議你可以現在去沖個澡，這樣兩個小時後體溫開始下降，正好適合睡覺。", [dateFormatter stringFromDate:[self decideShouldGoToBedTime]]];
    }
    
    NSArray *message = @[@"建議你不要再吃東西，讓胃開始休息了。",
                         @"建議你不要再看任何電子螢幕了，電子螢幕的亮光會延後你的睡眠週期。",  //讓眼睛開始休息。
                         bathMessage,
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
    
    NSDateComponents *currentDate = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    [components setYear:currentDate.year];
    [components setMonth:currentDate.month];
    [components setDay:currentDate.day];
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
        if (sleepData.wakeUpTime) {  //清醒狀態
            fireDate = [[NSArray alloc] initWithObjects:
                        [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:shouldGoToBedTime],
                        averageGoToSleepTime,
                        [NSDate dateWithTimeInterval:(60 * 60 * 16) sinceDate:sleepData.wakeUpTime], nil];
        } else {  //睡著狀態
            fireDate = [[NSArray alloc] initWithObjects:
                        [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:shouldGoToBedTime],
                        [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:shouldGoToBedTime],
                        averageGoToSleepTime,
                        NULLDate, nil];
        }
    } else {  //沒有睡眠資料時
        fireDate = [[NSArray alloc] initWithObjects:
                    [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:shouldGoToBedTime],
                    [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:shouldGoToBedTime],
                    [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:shouldGoToBedTime],
                    NULLDate,
                    NULLDate, nil];
    }
    
    return fireDate;
}

#pragma mark - Set

- (void)rescheduleIntelligentNotification
{
    [self cancelAllIntelligentNotification];
    [self setIntelligentNotification];
}

- (void)setIntelligentNotification
{
    NSArray *notification = [self decideNotificationTitle];
    NSArray *Message = [self decideMessage];
    NSArray *fireDate = [self decideFireDate];
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSArray *fetchArray = [[[SleepDataModel alloc] init] fetchSleepDataSortWithAscending:NO];
    if (fetchArray.count) {  //判斷有沒有資料，有資料的話就可以知道現在的睡眠狀態是什麼
        if ([[userPreferences valueForKey:@"睡眠狀態"] isEqualToString:@"清醒"]) {
            if ([userPreferences boolForKey:@"重複發出睡前通知"]) {
                for (NSInteger i = 0 ; i < [notification count] ; i++ ) {
                    if ([userPreferences boolForKey:notification[i]]) {
                        [self setLocalNotification:i RepeatOrNot:YES Message:Message[i] fireDate:fireDate[i]];
                    }
                }
            } else {
                for (NSInteger i = 0 ; i < [notification count] ; i++ ) {
                    if ([userPreferences boolForKey:notification[i]]) {
                        NSArray *fetchDataArray = [[[SleepDataModel alloc] init] fetchSleepDataSortWithAscending:NO];
                        self.sleepData = fetchDataArray[0];
                        if ((-[self.sleepData.wakeUpTime timeIntervalSinceNow]) / (60 * 60) <= 23) {  // 醒來超過二十四小時就不發出通知了
                            [self setLocalNotification:i RepeatOrNot:NO Message:Message[i] fireDate:fireDate[i]];
                        }
                    }
                }
            }
        }
    } else {
        //如果沒有資料，就一定是清醒狀態，要不讓起馬會有一筆只有上床時間的資料，所以不用檢查睡眠狀態。
        //要獨立分出來是因為在沒有資料時，如果想要設定睡前通知的時候會被 if (fetchArray.count) 這個判別是給過濾掉
        for (NSInteger i = 0 ; i < [notification count] - 2 ; i++ ) {  //「平均上床時間」、「醒來超過十六小時」兩個通知不用發出，因為沒有睡眠資料
            if ([userPreferences boolForKey:notification[i]]) {
                [self setLocalNotification:i RepeatOrNot:[userPreferences boolForKey:@"重複發出睡前通知"] Message:Message[i] fireDate:fireDate[i]];
            }
        }
    }
}

- (void)setLocalNotification:(NSInteger)i RepeatOrNot:(BOOL)Repeat Message:(NSString *)message fireDate:(NSDate *)fireDate
{
    [[[LocalNotification alloc] init] setLocalNotificationWithMessage:message
                                                             fireDate:fireDate
                                                          repeatOrNot:Repeat
                                                                sound:@"UILocalNotificationDefaultSoundName"
                                                             setValue:@"IntelligentNotification" forKey:@"NotificationType"
                                                             category:@"SleepNotification"];
}

- (void)setRemindUserToRecordWakeUpTime
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    
    NSDateComponents *currentDateComponents = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    [components setYear:currentDateComponents.year];
    [components setMonth:currentDateComponents.month];
    [components setDay:currentDateComponents.day];
    
    NSInteger averageWakeUpTimeInSecond = [[[[[Statistic alloc] init] showWakeUpTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
    if (averageWakeUpTimeInSecond) {
        [components setHour:averageWakeUpTimeInSecond / 3600];
        [components setMinute:((averageWakeUpTimeInSecond / 60) % 60)];
    } else {
        [components setHour:8];  //如果沒有資料預設是十點會發出通知，但因為後面會設定往後調兩個小時，所以在這邊設定八點
        [components setMinute:0];
    }
    
    NSDate *fireDate = [NSDate dateWithTimeInterval:60 * 60 * 2 sinceDate:[greCalendar dateFromComponents:components]];
    if ([[fireDate earlierDate:[NSDate date]] isEqualToDate:fireDate]) {
        fireDate = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:fireDate];
    }
    
    [[[LocalNotification alloc] init] setLocalNotificationWithMessage:@"你真的睡到現在！？趕快紀錄一下你是幾點起床的吧！"
                                                             fireDate:fireDate
                                                          repeatOrNot:NO
                                                                sound:@"UILocalNotificationDefaultSoundName"
                                                             setValue:@"提醒輸入起床時間" forKey:@"NotificationType" category:@"None"];
}

#pragma mark - Cancel

- (void)cancelAllIntelligentNotification
{
    [[[LocalNotification alloc] init] cancelLocalNotificaionWithValue:@"IntelligentNotification" foreKey:@"NotificationType"];
}

@end
