//
//  History3ViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "History3ViewController.h"

@interface History3ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate *passOverDate;

@end

@implementation History3ViewController

@synthesize passOverDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.date = passOverDate;
}

@end
