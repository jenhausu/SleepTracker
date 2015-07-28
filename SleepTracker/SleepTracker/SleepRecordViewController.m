//
//  SleepRecordViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SleepRecordViewController.h"
#import "GoogleAnalytics.h"

#import "SleepDataModel.h"
#import "SleepData.h"

#import "SleepNotification.h"

#import "Statistic.h"

@interface SleepRecordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alreadySleptLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, strong) SleepData *sleepData;
@property (nonatomic, strong) NSArray *fetchDataArray;

@property (nonatomic) NSUserDefaults *userPreferences;

@end

@implementation SleepRecordViewController

@synthesize timer, fetchDataArray, userPreferences;

#pragma mark - Lazy Initialization

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    
    return _sleepDataModel;
}

#pragma mark - view

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    [self stopTimer];
    
    if ([userPreferences boolForKey:@"顯示醒了多久"]) {
        self.alreadyAwakeTextLabel.text = @"已經醒了多久：";
        if (!self.alreadyAwakeTimeLabel.text) {  // 如果上次顯示頁面時就有要顯示醒了多久，就不要再把alreadyAwakeTimeLabel設為00:00:00，因為這樣會有幾秒的延遲
            self.alreadyAwakeTimeLabel.text = @"00:00:00";
        }
    } else {
        self.alreadyAwakeTextLabel.text = @" ";
        self.alreadyAwakeTimeLabel.text = nil;
    }
    
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    if ([fetchDataArray count]) {  //避免一開始完全沒有任何資
        self.sleepData = fetchDataArray[0];
        if (self.sleepData.wakeUpTime)  { //awake state
            [self.button setTitle:@"上床" forState:UIControlStateNormal];
            self.alreadySleptLabel.text = @"00:00:00";

            if ([userPreferences boolForKey:@"顯示醒了多久"]) [self startCountingAwakeTime];
        } else  {  //sleep state
            [self startCountingSleepTime];
            [self.button setTitle:@"起床" forState:UIControlStateNormal];
        }
    } else {
        [self.button setTitle:@"上床" forState:UIControlStateNormal];
        self.alreadySleptLabel.text = @"00:00:00";
        [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];  //如果沒有資料時設定睡眠狀態為清醒。
    }
    
    
    [self googleAnalytics];
}

- (void)googleAnalytics
{
    [[[GoogleAnalytics alloc] init] trackPageView:@"Record"];
}

- (IBAction)buttonPress:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"上床"])  //按下上床，進入睡眠狀態
    {
        [self.button setTitle:@"起床" forState:UIControlStateNormal];
        if ([userPreferences boolForKey:@"顯示醒了多久"]) {
            self.alreadyAwakeTextLabel.text = @"已經醒了多久：";
            self.alreadyAwakeTimeLabel.text = @"00:00:00";
        }
        
        NSDate *now = [NSDate date];
        [self.sleepDataModel addNewSleepdataAndAddGoToBedTime:now wakeUpTime:nil sleepTime:nil sleepType:nil];
        fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
        NSInteger const LATEST_DATA = 0;
        self.sleepData = fetchDataArray[LATEST_DATA];
        
        [self stopTimer];
        [self startCountingSleepTime];
        [userPreferences setValue:@"睡覺" forKey:@"睡眠狀態"];
        
        [[[SleepNotification alloc] init] goToBed];
    }else {
        UINavigationController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"wakeUpPage"];
        [self presentViewController:page2 animated:YES completion:nil];
        
        NSArray *viewControllers = page2.viewControllers;  //使用一個NSArray來取得UINavigationController下的所有viewControllers，只後再判斷誰是rootViewController
        UIViewController *rootViewController = [viewControllers objectAtIndex:[viewControllers count] - 1];  //??
        [rootViewController setValue:self forKey:@"delegate"];  //將delegate設成自己（指定自己為代理
    }
}

#pragma matk - delecate method

- (void)saveButtonPress
{
    [self.button setTitle:@"上床" forState:UIControlStateNormal];
    self.alreadySleptLabel.text = @"00:00:00";
    
    [self stopTimer];
    if ([userPreferences boolForKey:@"顯示醒了多久"]) [self startCountingAwakeTime];
    
    [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];
    
    [[[SleepNotification alloc] init] wakeUp];
}


#pragma mark - timer

- (void)startCountingSleepTime
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(updateTime)
                                           userInfo:@"Go To Bed"
                                            repeats:YES];
}

- (void)startCountingAwakeTime
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(updateTime)
                                           userInfo:@"Wake Up"
                                            repeats:YES];
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;

}

- (void)updateTime
{
    if ([timer.userInfo isEqualToString:@"Go To Bed"]) {
        self.alreadySleptLabel.text = [self stringFromTimeInterval:-[self.sleepData.goToBedTime timeIntervalSinceNow]];  //即時顯示已經睡了多久時間
    }else {
        if ([userPreferences integerForKey:@"醒來計時器歸零"] == 0) {  //照常計算
            self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
        } else if ([userPreferences integerForKey:@"醒來計時器歸零"] == 1) {  //超過二十四小時便不再計算
            if ((-[self.sleepData.wakeUpTime timeIntervalSinceNow]) / (60 * 60) <= 23) {
                self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
            } else {
                self.alreadyAwakeTimeLabel.text = @"00:00:00";
            }
        } else if ([userPreferences integerForKey:@"醒來計時器歸零"] == 2) {  //減去二十四小時繼續計算
            NSInteger awakeTime = -[self.sleepData.wakeUpTime timeIntervalSinceNow];
            while ((awakeTime / (60 * 60)) >= 24 ) {
                awakeTime = awakeTime - 86400;
            }
            self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:awakeTime];  //看上一筆資料離現在差幾天，就扣掉幾個24小時
        } else if ([userPreferences integerForKey:@"醒來計時器歸零"] == 3) {
            //從平均起床時間開始計算
            if ((-[self.sleepData.wakeUpTime timeIntervalSinceNow]) / (60 * 60) <= 23) {
                self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
            } else {
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
                
                NSDateComponents *currentDate = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
                [dateComponents setYear:currentDate.year];
                [dateComponents setMonth:currentDate.month];
                [dateComponents setDay:currentDate.day];
                
                NSInteger averageWakeUpTimeInSecond = [[[[[Statistic alloc] init] showWakeUpTimeDataInTheRecent:30] objectAtIndex:2] integerValue];
                if (averageWakeUpTimeInSecond) {
                    [dateComponents setHour:averageWakeUpTimeInSecond / 3600];
                    [dateComponents setMinute:((averageWakeUpTimeInSecond / 60) % 60)];
                } else {
                    [dateComponents setHour:9];
                    [dateComponents setMinute:0];
                }
                NSDate *averageWakeUpTime = [greCalendar dateFromComponents:dateComponents];
                
                
                if ([[averageWakeUpTime earlierDate:[NSDate date]] isEqualToDate:averageWakeUpTime]) {
                    self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:-[averageWakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
                } else {
                    currentDate = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                 fromDate:[NSDate dateWithTimeIntervalSinceNow:- 60 * 60 * 24]];
                    dateComponents.year = currentDate.year;
                    dateComponents.month = currentDate.month;
                    dateComponents.day = currentDate.day;
                    
                    averageWakeUpTime = [greCalendar dateFromComponents:dateComponents];
                    self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:-[averageWakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
                }
            }
        }
    }
}

#pragma mark -

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger time = (NSInteger)interval;
    NSInteger seconds = time % 60; // ％取餘數
    NSInteger minutes = (time / 60) % 60;
    NSInteger hours = (time / 3600);
    
    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
}

@end
