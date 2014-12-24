//
//  AlarmViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/23.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "AlarmViewController.h"

@interface AlarmViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *alreadySleptLabel;
@property (weak, nonatomic) IBOutlet UILabel *alreadyAwakeLabel;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow: 8 * 60 * 60];   //預設鬧鐘是八個小時之後
}

- (IBAction)buttonPress:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
