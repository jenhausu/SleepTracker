//
//  StatisticViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "StatisticViewController.h"
#import "GoogleAnalytics.h"
#import "Mixpanel_Model.h"

#import "Statistic.h"

@interface StatisticViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UILabel *segmentTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeMaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *wakeUpTimeMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *wakeUpTimeAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *wakeUpTimeMaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeMaxLabel;

@property (strong, nonatomic) Statistic *statistic;

@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeTooLate;
@property (weak, nonatomic) IBOutlet UILabel *getUpTooLate;
@property (nonatomic) NSString *goToBedTimeTooLateTem;
@property (nonatomic) NSString *getUpTooLateTem;

@end

@implementation StatisticViewController

@synthesize segmentTimeLabel;

- (Statistic *)statistic
{
    if (!_statistic) {
        _statistic = [[Statistic alloc]init];
    }
    return _statistic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    [self judgeWhichSegmentSelected];
}

- (IBAction)segmentChange:(id)sender
{
    [self judgeWhichSegmentSelected];
}

- (void)judgeWhichSegmentSelected
{
    switch (self.segment.selectedSegmentIndex) {
        case 0:
            [self showStatistic:7];
            [[[Mixpanel_Model alloc] init] trackEvent:@"查看「統計圖表」頁面" key:@"時間間隔" value:@"最近七天"];
            break;
        case 1:
            [self showStatistic:30];
            [[[Mixpanel_Model alloc] init] trackEvent:@"查看「統計圖表」頁面" key:@"時間間隔" value:@"最近一個月"];
            break;
        case 2:
            [self showStatistic:183];
            [[[Mixpanel_Model alloc] init] trackEvent:@"查看「統計圖表」頁面" key:@"時間間隔" value:@"最近半年"];
            break;
    }
}

- (void)showStatistic:(NSInteger)recent
{
    NSArray *goToBedTimeData, *wakeUpTimeData, *sleepTimeData;

    goToBedTimeData = [self.statistic goToBedTimeInTheRecent:recent];
    wakeUpTimeData = [self.statistic wakeUpTimeInTheRecent:recent];
    sleepTimeData = [self.statistic sleepTimeInTheRecent:recent];
    
    self.goToBedTimeMinLabel.text = [self stringFromTimeInterval:[goToBedTimeData[0] floatValue]];
    self.goToBedTimeMaxLabel.text = [self stringFromTimeInterval:[goToBedTimeData[1] floatValue]];
    self.goToBedTimeAvgLabel.text = [self stringFromTimeInterval:[goToBedTimeData[2] floatValue]];
    self.wakeUpTimeMinLabel.text = [self stringFromTimeInterval:[wakeUpTimeData[0] floatValue]];
    self.wakeUpTimeMaxLabel.text = [self stringFromTimeInterval:[wakeUpTimeData[1] floatValue]];
    self.wakeUpTimeAvgLabel.text = [self stringFromTimeInterval:[wakeUpTimeData[2] floatValue]];
    self.sleepTimeMinLabel.text = [self stringFromTimeInterval:[sleepTimeData[0] floatValue]];
    self.sleepTimeMaxLabel.text = [self stringFromTimeInterval:[sleepTimeData[1] floatValue]];
    self.sleepTimeAvgLabel.text = [self stringFromTimeInterval:[sleepTimeData[2] floatValue]];
    
    if (![self.sleepTimeAvgLabel.text isEqualToString:@"00:00"]) {  // 判斷有沒有資料
        self.getUpTooLate.text = [self.statistic calculateGetUpTooLatePercentage:recent];
        self.goToBedTimeTooLate.text = [self.statistic calculateGoToBedTooLatePercentage:recent];
    } else {
        self.getUpTooLate.text = @"早於九點起床：0/0 (0%)";
        self.goToBedTimeTooLate.text = @"早於十二點上床：0/0 (0%)";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"M/d(E)";
    segmentTimeLabel.text = [NSString stringWithFormat:@"%@ ~ %@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(60 * 60 * 24 * (recent - 1))]], [dateFormatter stringFromDate:[NSDate date]]];
    
    
    [self trackPageView:recent];
}

- (void)trackPageView:(NSInteger)recent
{
    switch (recent) {
        case 7:
            [[[GoogleAnalytics alloc] init] trackPageView:@"Statistic 最近一週"];
            break;
        case 30:
            [[[GoogleAnalytics alloc] init] trackPageView:@"Statistic 最近一個月"];
            break;
        case 183:
            [[[GoogleAnalytics alloc] init] trackPageView:@"Statistic 最近半年"];
            break;
    }
}

- (NSString *)stringFromTimeInterval:(NSInteger)timeInterval
{
    NSInteger minutes = labs((timeInterval / 60) % 60);
    NSInteger hours = abs((int)(timeInterval / 3600));  //取整數
    
    return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
}

@end
