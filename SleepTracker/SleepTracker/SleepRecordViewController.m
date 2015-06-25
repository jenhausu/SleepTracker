//
//  SleepRecordViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SleepRecordViewController.h"

#import "SleepDataModel.h"
#import "SleepData.h"

#import "SleepNotification.h"

#import "Statistic.h"

@interface SleepRecordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alreadySleptLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, strong) NSTimer *timer;

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
    
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    if ([fetchDataArray count]) {  //避免一開始完全沒有任何資
        self.sleepData = fetchDataArray[0];
        if (self.sleepData.wakeUpTime)  //awake state
        {
            [self stopTimer];
            [self.button setTitle:@"上床" forState:UIControlStateNormal];

            switch ([userPreferences integerForKey:@"醒來計時器歸零"]) {
                case 0:
                    [self startCountingAwakeTime];
                    break;
                case 1:
                    if ((-[self.sleepData.wakeUpTime timeIntervalSinceNow]) / (60 * 60) <= 23) {
                        [self startCountingAwakeTime];
                    } else {
                        [self stopTimer];
                        self.alreadyAwakeLabel.text = @"00:00:00";
                    }
                    break;
                case 2:
                    [self startCountingAwakeTime];
                    break;
                case 3:
                    [self startCountingAwakeTime];
                    break;
            }
        }
        else  //sleep state
        {
            [self startCountingSleepTime];
            [self.button setTitle:@"起床" forState:UIControlStateNormal];
            self.alreadyAwakeLabel.text = @"00:00:00";
        }
    } else {
        [self.button setTitle:@"上床" forState:UIControlStateNormal];
        self.alreadySleptLabel.text = @"00:00:00";
        self.alreadyAwakeLabel.text = @"00:00:00";
        [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];  //如果沒有資料時設定睡眠狀態為清醒。
    }
}

- (IBAction)buttonPress:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"上床"])
    {
        [self.button setTitle:@"起床" forState:UIControlStateNormal];
        self.alreadyAwakeLabel.text = @"00:00:00";
        
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
    [self startCountingAwakeTime];
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
            self.alreadyAwakeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
        } else if ([userPreferences integerForKey:@"醒來計時器歸零"] == 1) {  //超過二十四小時便不再計算
            self.alreadyAwakeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
        } else if ([userPreferences integerForKey:@"醒來計時器歸零"] == 2) {  //減去二十四小時繼續計算
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"DDD"];  // 1~366 一年的第幾天
            
            NSInteger today = [[formatter stringFromDate:[NSDate date]] integerValue];
            NSInteger dataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue];
            
            self.alreadyAwakeLabel.text = [self stringFromTimeInterval:((-[self.sleepData.wakeUpTime timeIntervalSinceNow]) - (86400 * (today - dataDate)))];  //看上一筆資料離現在差幾天，就扣掉幾個24小時
        } else if ([userPreferences integerForKey:@"醒來計時器歸零"] == 3) {
            //從平均起床時間開始計算
            if ((-[self.sleepData.wakeUpTime timeIntervalSinceNow]) / (60 * 60) <= 23) {
                self.alreadyAwakeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
            } else {
                NSDateComponents *components = [[NSDateComponents alloc] init];
                NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
                
                NSDateComponents *currentDate = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
                [components setYear:currentDate.year];
                [components setMonth:currentDate.month];
                [components setDay:currentDate.day];
                
                NSInteger averageWakeUpTimeInSecond = [[[[[Statistic alloc] init] showWakeUpTimeDataInTheRecent:30] objectAtIndex:2] integerValue];
                if (averageWakeUpTimeInSecond) {
                    [components setHour:averageWakeUpTimeInSecond / 3600];
                    [components setMinute:((averageWakeUpTimeInSecond / 60) % 60)];
                } else {
                    [components setHour:9];
                    [components setMinute:0];
                }
                
                self.alreadyAwakeLabel.text = [self stringFromTimeInterval:-[[greCalendar dateFromComponents:components] timeIntervalSinceNow]];  //即時顯示已經醒了多久
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
