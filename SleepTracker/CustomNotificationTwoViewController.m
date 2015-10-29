//
//  CustomNotificationTwoViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomNotificationTwoViewController.h"
#import "GoogleAnalytics.h"

#import "CustomNotification-Model.h"

@interface CustomNotificationTwoViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) CustomNotification_Model *customNotification;

@end

@implementation CustomNotificationTwoViewController

- (CustomNotification_Model *)customNotification
{
    if (!_customNotification) {
        _customNotification = [[CustomNotification_Model alloc] init];
    }

    return _customNotification;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"Add New Custom Notification"];
}

- (IBAction)save:(id)sender
{
    [self.customNotification addNewCustomNotification:self.textField.text
                                             fireDate:self.datePicker.date
                                                sound:@"UILocalNotificationDefaultSoundName"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
