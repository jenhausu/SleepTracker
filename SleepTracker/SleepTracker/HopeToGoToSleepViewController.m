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

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *TextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation HopeToGoToSleepViewController

@synthesize dateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
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
            break;
        }
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
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
        
        [[[LocalNotification alloc] init] setLocalNotificationWithMessage:self.TextField.text
                                                                 fireDate:self.datePicker.date
                                                              repeatOrNot:YES
                                                                    Sound:@"UILocalNotificationDefaultSoundName"
                                                                 setValue:@"HopeToGoToBed" forKey:@"NotificationType"];
    }
}

- (IBAction)dateValueChanged:(id)sender {
    self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

@end
