//
//  SleepRecordViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SleepRecordViewController.h"
#import "GoogleAnalytics.h"
#import "Mixpanel_Model.h"

#import "SleepDataModel.h"
#import "SleepData.h"

#import "SleepNotification.h"

#import "Statistic.h"

@interface SleepRecordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alreadySleptLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeTimeLabel;
@property (nonatomic) NSDate *wakeUpTime;
@property (nonatomic) NSInteger nap;
@property (nonatomic) NSDate *averageWakeUpTime;

@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, strong) SleepData *sleepData;
@property (nonatomic, strong) NSArray *fetchDataArray;

@property (nonatomic) NSUserDefaults *userPreferences;

@end

@implementation SleepRecordViewController

@synthesize timer, fetchDataArray, userPreferences, wakeUpTime, nap, averageWakeUpTime;

#pragma mark - Lazy Initialization

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    
    return _sleepDataModel;
}

#pragma mark - view

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.alreadySleptLabel.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightLight];
    self.alreadyAwakeTimeLabel.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightLight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    [self stopTimer];
    
    // 決定要不要顯示計算醒得喔久
    if ([userPreferences boolForKey:@"計算醒了多久"]) {
        self.alreadyAwakeTextLabel.text = @"已經醒了多久：";
        if (!self.alreadyAwakeTimeLabel.text) {  // 如果上次顯示頁面時就有要顯示醒了多久，就不要再把alreadyAwakeTimeLabel設為00:00:00，因為這樣會有幾秒的延遲
            self.alreadyAwakeTimeLabel.text = @"00:00:00";
        }
    } else {
        self.alreadyAwakeTextLabel.text = @" ";
        self.alreadyAwakeTimeLabel.text = nil;
    }
    
    // 決定按鈕要顯示什麼，還有根據睡眠狀態決定要計時什麼
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    if ([fetchDataArray count]) {  //避免一開始完全沒有任何資
        self.sleepData = fetchDataArray[0];
        if (self.sleepData.wakeUpTime)  { //awake state
            [self.button setTitle:@"上床" forState:UIControlStateNormal];
            self.alreadySleptLabel.text = @"00:00:00";

            if ([userPreferences boolForKey:@"計算醒了多久"]) [self startCountingAwakeTime];
            
            // 校正計算起床時間的數據
            nap = 0;
            for (NSInteger i = 0 ; i < fetchDataArray.count ; i++ ) {
                self.sleepData = fetchDataArray[i];
                if ([self.sleepData.sleepType isEqualToString:@"一般"]) {
                    wakeUpTime = self.sleepData.wakeUpTime; // 設定起床時間的基準點
                    break;
                } else {
                    nap += [self.sleepData.sleepTime integerValue];  // 計算中間小睡的時間有多少
                }
            }
            
            // 計算平均起床時間
            if ([userPreferences integerForKey:@"醒來計時器計算方式"] == 3) {
                NSInteger awakeTime = -([wakeUpTime timeIntervalSinceNow] + nap);
                if (awakeTime / (60 * 60) > 23) {  // 醒來時間超過一天才開始用平均起床時間計算
                    // 變數宣告
                    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *currentDate = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
                    
                    // 設定年月日
                    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                    dateComponents.year = currentDate.year;
                    dateComponents.month = currentDate.month;
                    dateComponents.day = currentDate.day;
                    
                    // 設定時分
                    NSInteger averageWakeUpTimeInSecond = [[[[[Statistic alloc] init] wakeUpTimeInTheRecent:30] objectAtIndex:2] integerValue];
                    if (averageWakeUpTimeInSecond) {  // 如果有資料
                        dateComponents.hour = averageWakeUpTimeInSecond / 3600;
                        dateComponents.minute = ((averageWakeUpTimeInSecond / 60) % 60);
                    } else {  //  如果沒資料
                        dateComponents.hour = 9;
                        dateComponents.minute = 0;
                    }
                    
                    // 最後輸出結果
                    averageWakeUpTime = [greCalendar dateFromComponents:dateComponents];
                    
                    // 如果現在時間比平均起床時間還早，必須把平均起床時間往前調一天，視現在的狀態為已經快一整天沒睡
                    if ([[averageWakeUpTime earlierDate:[NSDate date]] isEqualToDate:[NSDate date]]) {
                        currentDate = [greCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                     fromDate:[NSDate dateWithTimeIntervalSinceNow:- 60 * 60 * 24]];
                        dateComponents.year = currentDate.year;
                        dateComponents.month = currentDate.month;
                        dateComponents.day = currentDate.day;
                        
                        averageWakeUpTime = [greCalendar dateFromComponents:dateComponents];
                    }
                }
            }
        } else  {  //sleep state
            [self startCountingSleepTime];
            [self.button setTitle:@"起床" forState:UIControlStateNormal];
        }
    } else {
        [self.button setTitle:@"上床" forState:UIControlStateNormal];
        self.alreadySleptLabel.text = @"00:00:00";
        [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];  //如果沒有資料時設定睡眠狀態為清醒。
    }
    
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"Record"];
    [[[Mixpanel_Model alloc] init] trackEvent:@"查看「紀錄」頁面"];
}

- (IBAction)buttonPress:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"上床"])  //按下上床，進入睡眠狀態
    {
        [self.button setTitle:@"起床" forState:UIControlStateNormal];
        if ([userPreferences boolForKey:@"計算醒了多久"]) {
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
    if ([userPreferences boolForKey:@"計算醒了多久"]) [self startCountingAwakeTime];
    
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
        NSInteger awakeTime = -([wakeUpTime timeIntervalSinceNow] + nap);

        if ([userPreferences integerForKey:@"醒來計時器計算方式"] == 0) {  //照常計算
            self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:awakeTime];
        } else if ([userPreferences integerForKey:@"醒來計時器計算方式"] == 1) {  //超過二十四小時便不再計算
            if (awakeTime / (60 * 60) <= 23) {
                self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:awakeTime];
            } else {
                self.alreadyAwakeTimeLabel.text = @"00:00:00";
            }
        } else if ([userPreferences integerForKey:@"醒來計時器計算方式"] == 2) {  //減去二十四小時繼續計算
            while ((awakeTime / (60 * 60)) >= 24 ) {
                awakeTime = awakeTime - 86400;
            }
            self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:awakeTime];  //看上一筆資料離現在差幾天，就扣掉幾個24小時
        } else if ([userPreferences integerForKey:@"醒來計時器計算方式"] == 3) {  //從平均起床時間開始計算
            if (awakeTime / (60 * 60) <= 23) {  // 一天以內正常計算醒來時間
                self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:awakeTime];
            } else {
                awakeTime = -([averageWakeUpTime timeIntervalSinceNow] + nap);
                self.alreadyAwakeTimeLabel.text = [self stringFromTimeInterval:awakeTime];
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
