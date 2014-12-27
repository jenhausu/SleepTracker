//
//  WakeUp2ViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "WakeUp2ViewController.h"

@interface WakeUp2ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDate *passOverDate;

@end

@implementation WakeUp2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.date = self.passOverDate;
}

- (IBAction)valueChange:(id)sender {
    
}

@end
