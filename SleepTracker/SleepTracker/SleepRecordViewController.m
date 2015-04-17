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
#import "IntelligentNotification.h"
#import "CustomNotification-Model.h"

@interface SleepRecordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alreadySleptLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) SleepDataModel *sleepDataModel;

@property (nonatomic, strong) SleepData *sleepData;
@property (nonatomic, strong) NSArray *fetchDataArray;

@property (nonatomic, strong) IntelligentNotification *intelligentNotification;
@property (nonatomic, strong) CustomNotification_Model *customNotification;

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

- (IntelligentNotification *)intelligentNotification
{
    if (!_intelligentNotification) {
        _intelligentNotification = [[IntelligentNotification alloc] init];
    }
    
    return _intelligentNotification;
}

- (CustomNotification_Model *)customNotification
{
    if (!_customNotification) {
        _customNotification = [[CustomNotification_Model alloc] init];
    }
    
    return _customNotification;
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
            [self startCountingAwakeTime];
            [self.button setTitle:@"上床" forState:UIControlStateNormal];
        }
        else  //sleep state
        {
            [self startCountingSleepTime];
            [self.button setTitle:@"起床" forState:UIControlStateNormal];
        }
    } else {
        [self.button setTitle:@"上床" forState:UIControlStateNormal];
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
        
        
        [self.intelligentNotification deleteAllIntelligentNotification];
        [self.customNotification cancelAllCustomNotification];
        
        [userPreferences setValue:@"睡覺" forKey:@"睡眠狀態"];
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
    [self.intelligentNotification rescheduleIntelligentNotification];
    [self.customNotification setCustomNotificatioin];
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

- (void)updateTime
{
    if ([timer.userInfo isEqualToString:@"Go To Bed"]) {
        self.alreadySleptLabel.text = [self stringFromTimeInterval:-[self.sleepData.goToBedTime timeIntervalSinceNow]];  //即時顯示已經睡了多久時間
    }else {
        self.alreadyAwakeLabel.text = [self stringFromTimeInterval:-[self.sleepData.wakeUpTime timeIntervalSinceNow]];  //即時顯示已經醒了多久
    }
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
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
