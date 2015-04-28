//
//  StatisticViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "StatisticViewController.h"

#import "Statistic.h"

@interface StatisticViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

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
            break;
        case 1:
            [self showStatistic:30];
            break;
        case 2:
            [self showStatistic:183];
            break;
    }
}

- (void)showStatistic:(NSInteger)recent
{
    NSArray *goToBedTimeData, *wakeUpTimeData, *sleepTimeData;

    goToBedTimeData = [self.statistic showGoToBedTimeDataInTheRecent:recent];
    wakeUpTimeData = [self.statistic showWakeUpTimeDataInTheRecent:recent];
    sleepTimeData = [self.statistic showSleepTimeDataInTheRecent:recent];
    
    self.goToBedTimeMinLabel.text = [self stringFromTimeInterval:[goToBedTimeData[0] floatValue]];
    self.goToBedTimeMaxLabel.text = [self stringFromTimeInterval:[goToBedTimeData[1] floatValue]];
    self.goToBedTimeAvgLabel.text = [self stringFromTimeInterval:[goToBedTimeData[2] floatValue]];
    self.wakeUpTimeMinLabel.text = [self stringFromTimeInterval:[wakeUpTimeData[0] floatValue]];
    self.wakeUpTimeMaxLabel.text = [self stringFromTimeInterval:[wakeUpTimeData[1] floatValue]];
    self.wakeUpTimeAvgLabel.text = [self stringFromTimeInterval:[wakeUpTimeData[2] floatValue]];
    self.sleepTimeMinLabel.text = [self stringFromTimeInterval:[sleepTimeData[0] floatValue]];
    self.sleepTimeMaxLabel.text = [self stringFromTimeInterval:[sleepTimeData[1] floatValue]];
    self.sleepTimeAvgLabel.text = [self stringFromTimeInterval:[sleepTimeData[2] floatValue]];
    
    self.getUpTooLate.text = [NSString stringWithFormat:@"%0.01f", [self.statistic calculateGetUpTooLatePercentage:recent]];
    self.goToBedTimeTooLate.text = [NSString stringWithFormat:@"%0.01f", [self.statistic calculateGoToBedTooLatePercentage:recent]];
}

- (NSString *)stringFromTimeInterval:(NSInteger)timeInterval
{
    NSInteger minutes = labs((timeInterval / 60) % 60);
    NSInteger hours = abs((int)(timeInterval / 3600));  //取整數
    
    return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
}

@end
