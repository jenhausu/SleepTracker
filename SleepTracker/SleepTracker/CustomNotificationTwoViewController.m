//
//  CustomNotificationTwoViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomNotificationTwoViewController.h"

@interface CustomNotificationTwoViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation CustomNotificationTwoViewController

@synthesize formatter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"u/MM/dd EEE ahh:mm"];
    self.label.text = [formatter stringFromDate:self.datePicker.date];
}

- (IBAction)valueChanged:(id)sender {
    self.label.text = [formatter stringFromDate:self.datePicker.date];
}

- (IBAction)save:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
