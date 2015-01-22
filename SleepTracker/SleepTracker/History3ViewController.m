//
//  History3ViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "History3ViewController.h"

#import "History2TableViewController.h"

@interface History3ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) NSDate *passOverDate;
@property (strong, nonatomic) History2TableViewController *History2ViewController;

@end

@implementation History3ViewController

@synthesize passOverDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.date = passOverDate;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        if ([self.title isEqualToString:@"上床時間"]) {
            [self.History2ViewController setValue:self.datePicker.date forKey:@"goToBedTime"];
        }
        else if ([self.title isEqualToString:@"起床時間"]) {
            [self.History2ViewController setValue:self.datePicker.date forKey:@"wakeUpTime"];
        }
    }
}

@end
