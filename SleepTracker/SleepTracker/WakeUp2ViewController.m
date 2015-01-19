//
//  WakeUp2ViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "WakeUp2ViewController.h"

#import "SleepDataModel.h"
#import "WakeUpTableViewController.h"

@interface WakeUp2ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDate *passOverDate;

@property (strong, nonatomic) NSDateFormatter *formatter;

@property (nonatomic, strong) WakeUpTableViewController *wakeUpViewController;

@end

@implementation WakeUp2ViewController

@synthesize formatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.date = self.passOverDate;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"u/MM/dd EEE ahh:mm"];
    self.dateLabel.text = [formatter stringFromDate:self.passOverDate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer in the navigation stack.
        
        if ([self.title isEqualToString:@"上床時間"]) {    //更新資料
            [self.wakeUpViewController setValue:self.datePicker.date forKey:@"goToBedTime"];  //[delegate2 passDate:self.datePicker.date backToWhichSleepTime:@"goToBedTime"];
        }
        else if ([self.title isEqualToString:@"起床時間"]) {
            [self.wakeUpViewController setValue:self.datePicker.date forKey:@"wakeUpTime"];  //[delegate2 passDate:self.datePicker.date backToWhichSleepTime:@"wakeUpTime"];
        }
    }
    [super viewWillDisappear:animated];
}

@end
