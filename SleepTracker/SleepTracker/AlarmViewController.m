//
//  AlarmViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/23.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "AlarmViewController.h"

@interface AlarmViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation AlarmViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.date = [NSDate date];   //預設鬧鐘是八個小時之後
}

@end
