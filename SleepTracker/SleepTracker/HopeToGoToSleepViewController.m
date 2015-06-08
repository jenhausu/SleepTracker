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
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation HopeToGoToSleepViewController

@synthesize dateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Default ShouldToGoBedTime Date
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    [components setHour:23];
    [components setMinute:0];
    self.datePicker.date = [calendar dateFromComponents:components];
    
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    if ([userPreferences valueForKey:@"HopeToGoToBedTime"]) {
        self.datePicker.date = [userPreferences valueForKey:@"HopeToGoToBedTime"];
    }
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"a hh:mm"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
        [userPreferences setValue:self.datePicker.date forKey:@"HopeToGoToBedTime"];
        
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
