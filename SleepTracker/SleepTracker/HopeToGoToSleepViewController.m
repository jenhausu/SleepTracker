//
//  HopeToGoToSleepViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "HopeToGoToSleepViewController.h"

#import "LocalNotification.h"

@interface HopeToGoToSleepViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchController;
@property (weak, nonatomic) NSUserDefaults *userPreferces;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *TextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) LocalNotification *localNotification;

@end

@implementation HopeToGoToSleepViewController

@synthesize userPreferces, dateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"希望上床時間";
    
    userPreferces = [NSUserDefaults standardUserDefaults];
    self.switchController.on = [userPreferces boolForKey:@"hopeToGoToBed"];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"aa hh:mm"];

    
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    NSString *value;
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        userInfo = localNotification.userInfo;
        value = [userInfo objectForKey:@"NotificationType"];
        if ([value isEqualToString:@"HopeToGoToBed"])
        {
            self.datePicker.date = localNotification.fireDate;
            self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];

            break;
        }
    }
}

- (IBAction)switchBeTouched:(id)sender {
    UISwitch *switchControl = sender;
    [userPreferces setBool:switchControl.on forKey:@"hopeToGoToBed"];
    
    if (switchControl.on) {
        self.localNotification = [[LocalNotification alloc] init];
        [self.localNotification setLocalNotificationWithMessage:self.TextField.text
                                                       fireDate:self.datePicker.date
                                                    repeatOrNot:YES
                                                          Sound:@"UILocalNotificationDefaultSoundName"
                                                       setValue:@"HopeToGoToBed" forKey:@"NotificationType"];
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
        UILocalNotification *localNotification;
        NSDictionary *userInfo;
        NSString *value;
        for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
        {
            localNotification = arrayOfAllLocalNotification[row];
            
            userInfo = localNotification.userInfo;
            value = [userInfo objectForKey:@"NotificationType"];
            
            if ([value isEqualToString:@"HopeToGoToBed"])
            {
                [application cancelLocalNotification:localNotification];
                break;
            }
        }
    }
}

- (IBAction)update:(id)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    NSString *value;
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        
        userInfo = localNotification.userInfo;
        value = [userInfo objectForKey:@"NotificationType"];
        
        if ([value isEqualToString:@"HopeToGoToBed"])
        {
            [application cancelLocalNotification:localNotification];
            
            self.localNotification = [[LocalNotification alloc] init];
            [self.localNotification setLocalNotificationWithMessage:self.TextField.text
                                                           fireDate:self.datePicker.date
                                                        repeatOrNot:YES
                                                              Sound:@"UILocalNotificationDefaultSoundName"
                                                           setValue:@"HopeToGoToBed" forKey:@"NotificationType"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新希望上床時間"
                                                            message:@"成功！"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"確定", nil];
            [alert show];
            
            break;
        }
    }
}

- (IBAction)dateValueChanged:(id)sender {
    self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

@end
