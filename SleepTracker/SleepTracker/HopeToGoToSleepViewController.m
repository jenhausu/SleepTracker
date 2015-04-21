//
//  HopeToGoToSleepViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "HopeToGoToSleepViewController.h"

#import "LocalNotification.h"
#import "IntelligentNotification.h"

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
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    [components setHour:23];
    [components setMinute:0];
    self.datePicker.date = [calendar dateFromComponents:components];
    
    
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
        
        [[[IntelligentNotification alloc] init] rescheduleIntelligentNotification];
    }
}

- (IBAction)dateValueChanged:(id)sender {
    self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

#pragma mark - 把虛擬鍵盤收起來

//點擊其它地方讓鍵盤收起來
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//按下 return 鍵收起鍵盤
- (IBAction)returnPress:(id)sender {
    [sender resignFirstResponder];
}

@end
