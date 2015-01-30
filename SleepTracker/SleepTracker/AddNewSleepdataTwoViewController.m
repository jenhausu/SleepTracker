//
//  AddNewSleepdataTwoViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/30.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "AddNewSleepdataTwoViewController.h"

@interface AddNewSleepdataTwoViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSDate *receiveDate;

@end

@implementation AddNewSleepdataTwoViewController

@synthesize dateFormatter, receiveDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"u/MM/dd EEE ahh:mm"];
    self.label.text = [dateFormatter stringFromDate:receiveDate];
    
    self.datePicker.date = receiveDate;
}

- (IBAction)valueChanged:(id)sender {
    self.label.text = [dateFormatter stringFromDate:self.datePicker.date];
}

@end
