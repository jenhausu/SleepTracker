//
//  CustomNotificationTwoViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomNotificationTwoViewController.h"

#import "LocalNotification.h"

@interface CustomNotificationTwoViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) LocalNotification *localNotification;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

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
    self.localNotification = [[LocalNotification alloc] init];
    [self.localNotification setLocalNotificationWithMessage:self.textField.text
                                                   fireDate:self.datePicker.date
                                                repeatOrNot:self.switchControl.on
                                                      Sound:@"UILocalNotificationDefaultSoundName"
                                                   setValue:@"CustomNotification" forKey:@"NotificationType"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
