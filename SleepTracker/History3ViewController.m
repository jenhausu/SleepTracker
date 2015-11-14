//
//  History3ViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "History3ViewController.h"
#import "GoogleAnalytics.h"
#import "Mixpanel_Model.h"

#import "History2TableViewController.h"

#import "SleepDataModel.h"
#import "SleepData.h"

@interface History3ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSString *DateType;
@property (strong, nonatomic) NSDate *goToBedTime;
@property (strong, nonatomic) NSDate *wakeUpTime;
@property (strong, nonatomic) NSNumber *selectedRow;
@property (strong, nonatomic) History2TableViewController *History2ViewController;

@property (strong, nonatomic) SleepDataModel *sleepDataModel;
@property (strong, nonatomic) SleepData *sleepData;
@property (strong, nonatomic) NSArray *fetchDataArray;

@end

@implementation History3ViewController

@synthesize dateFormatter, DateType, goToBedTime, wakeUpTime, fetchDataArray, selectedRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"u/MM/dd EEE ahh:mm"];
    
    NSInteger selecetedRow = [selectedRow integerValue];

    self.sleepDataModel = [[SleepDataModel alloc] init];
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    if ([DateType isEqualToString:@"goToBedTime"])
    {
        self.datePicker.date = goToBedTime;
        
        if (selecetedRow != fetchDataArray.count - 1) {
            self.sleepData = fetchDataArray[[selectedRow integerValue] + 1];
            self.datePicker.minimumDate = self.sleepData.wakeUpTime;  //上床時間可設定的最小值限制為上一筆資料的起床時間
        }
        self.datePicker.maximumDate = wakeUpTime;  //上床時間可設定的最大值限制為起床時間
        
        self.dateLabel.text = [dateFormatter stringFromDate:goToBedTime];
    }
    else if ([DateType isEqualToString:@"wakeUpTime"])
    {
        self.datePicker.date = wakeUpTime;
        
        self.datePicker.minimumDate = goToBedTime;  //起床時間可設定的最小值限制為上床時間
        if (selecetedRow != 0) {
            self.sleepData = fetchDataArray[selecetedRow - 1];
            self.datePicker.maximumDate = self.sleepData.goToBedTime;  //最大值為現在時間，起床時間不可以設為未來的時間，要不計算清醒時間會錯亂
        } else if (selecetedRow == 0) {
            self.datePicker.maximumDate = [NSDate date];  //最大值為現在時間，起床時間不可以設為未來的時間，要不計算清醒時間會錯亂
        }
        
        self.dateLabel.text = [dateFormatter stringFromDate:wakeUpTime];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self trackPageView];
    [self mixpanelAnalytics];
}

- (void)trackPageView
{
    if ([DateType isEqualToString:@"goToBedTime"]) {
        [[[GoogleAnalytics alloc] init] trackPageView:@"History ChangeValue GoToBedTime"];
    } else if ([DateType isEqualToString:@"wakeUpTime"]) {
        [[[GoogleAnalytics alloc] init] trackPageView:@"History ChangeValue WakeUpTime"];
    }
}

- (void)mixpanelAnalytics
{
    if ([DateType isEqualToString:@"goToBedTime"]) {
        [[[Mixpanel_Model alloc] init] trackEvent:@"History3" key:@"上床或起床時間" value:@"上床時間"];
    } else if ([DateType isEqualToString:@"wakeUpTime"]) {
        [[[Mixpanel_Model alloc] init] trackEvent:@"History3" key:@"上床或起床時間" value:@"起床時間"];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        if ([DateType isEqualToString:@"goToBedTime"]) {
            [self.History2ViewController setValue:self.datePicker.date forKey:@"goToBedTime"];
        }
        else if ([DateType isEqualToString:@"wakeUpTime"]) {
            [self.History2ViewController setValue:self.datePicker.date forKey:@"wakeUpTime"];
        }
    }
}

- (IBAction)valueChanged:(id)sender
{
    self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

@end
