//
//  IntelligentNotificationTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "IntelligentNotificationTableViewController.h"

#import "IntelligentNotification.h"
#import "SleepDataModel.h"
#import "SleepData.h"

@interface IntelligentNotificationTableViewController ()  <UIAlertViewDelegate>

@property (strong, nonatomic) IntelligentNotification *intelligentNotification;
@property (strong, nonatomic) NSArray *fireDate;
@property (strong, nonatomic) NSArray *notificationName;

@property (nonatomic) NSArray *fetchDataArray;
@property (nonatomic) UISwitch *switchControl;

@property (nonatomic) SleepData *sleepData;

@property (nonatomic) NSUserDefaults *userPreferences;

@property (nonatomic) NSString *footerText;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger remainingCounts;

@end

@implementation IntelligentNotificationTableViewController

@synthesize notificationName, fireDate, fetchDataArray, userPreferences, footerText, timer, remainingCounts;

#pragma mark - Lazy initialization

- (IntelligentNotification *)intelligentNotification
{
    if (!_intelligentNotification) {
        _intelligentNotification = [[IntelligentNotification alloc] init];
    }
    return _intelligentNotification;
}

#pragma mark - view

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    self.title = @"智能提醒";
    
    fireDate = [self.intelligentNotification decideFireDate];
    notificationName = [self.intelligentNotification decideNotificationTitle];
    
    fetchDataArray = [[[SleepDataModel alloc] init] fetchSleepDataSortWithAscending:YES];
    if (fetchDataArray.count) {
        self.sleepData = fetchDataArray[0];
    }
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = notificationName[indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = notificationName[4];
    } else {
        cell.textLabel.text = notificationName[5];
    }
    cell.detailTextLabel.text = [formatter stringFromDate:fireDate[indexPath.row]];

    UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
    cell.accessoryView = switchControl;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
    {
        switchControl.on = [userPreferences boolForKey:notificationName[indexPath.row]];
        cell.detailTextLabel.text = [formatter stringFromDate:fireDate[indexPath.row]];

        if (indexPath.row == 0) {
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
        }
        else if (indexPath.row == 1) {
            [switchControl addTarget:self action:@selector(switchChanged2:) forControlEvents:UIControlEventValueChanged];
        }
        else if (indexPath.row == 2) {
            [switchControl addTarget:self action:@selector(switchChanged3:) forControlEvents:UIControlEventValueChanged];
        }
        else if (indexPath.row == 3) {
            [switchControl addTarget:self action:@selector(switchChanged4:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            switchControl.on = [userPreferences boolForKey:notificationName[4]];
            [switchControl addTarget:self action:@selector(switchChanged5:) forControlEvents:UIControlEventValueChanged];
            
            if (fetchDataArray.count >= 2 || (fetchDataArray.count == 1 && self.sleepData.wakeUpTime > 0) ) {
                cell.detailTextLabel.text = [formatter stringFromDate:fireDate[4]];
            } else {
                cell.detailTextLabel.text = @"--:--";
            }
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            switchControl.on = [userPreferences boolForKey:notificationName[5]];
            [switchControl addTarget:self action:@selector(switchChanged6:) forControlEvents:UIControlEventValueChanged];
            
            if (fetchDataArray.count >= 2 || (fetchDataArray.count == 1 && self.sleepData.wakeUpTime > 0) ) {
                cell.detailTextLabel.text = [formatter stringFromDate:fireDate[5]];
            } else {
                cell.detailTextLabel.text = @"--:--";
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 45;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        CGRect rect = CGRectMake(20, 0, 280, 50);
        UIView *footerView = [[UIView alloc] initWithFrame:rect];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:rect];
        
        footerLabel.text = footerText;
        footerLabel.font = [UIFont fontWithName:@"AppleGothic" size:10];
        footerLabel.textColor = [UIColor grayColor];
        footerLabel.numberOfLines = 0;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        
        [footerView addSubview:footerLabel];
        return footerView;
    } else {
        return nil;
    }
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[0]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    if (self.switchControl.on) {
        footerText = @"App 會在應該上床睡覺時間的前三個小時發出通知，提醒你不要再吃東西了，好讓腸胃開始休息。";
    } else {
        footerText = @"";
    }
    
    [self updateSectionOneFooter];
}

- (void)switchChanged2:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[1]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    if (self.switchControl.on) {
        footerText = @"App 會在應該上床睡覺時間的前一個小時發出通知，提醒你不要再看電子螢幕了。";
    } else {
        footerText = @"";
    }
    
    [self updateSectionOneFooter];
}

- (void)switchChanged3:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[2]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    if (self.switchControl.on) {
        footerText = @"App 會在應該上床睡覺時間的前兩個小時發出通知，提醒你如果你還沒去洗澡，建議你可以趕快去洗澡，這樣兩個小時後體溫開始下降，最適合入睡。";
    } else {
        footerText = @"";
    }
    
    [self updateSectionOneFooter];
}

- (void)switchChanged4:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[3]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    if (self.switchControl.on) {
        footerText = @"App 會在午夜時發出通知";
    } else {
        footerText = @"";
    }
    
    [self updateSectionOneFooter];
}

- (void)switchChanged5:(id)sender
{
    self.switchControl = sender;
    
    if (fetchDataArray.count >= 2 || (fetchDataArray.count == 1 && self.sleepData.wakeUpTime > 0) ) {
        [userPreferences setBool:self.switchControl.on forKey:notificationName[4]];
        [self.intelligentNotification rescheduleIntelligentNotification];
    } else {
        [self dontHaveEnoughDataAlert];
    }
}

- (void)switchChanged6:(id)sender
{
    self.switchControl = sender;
    
    if (fetchDataArray.count >= 2 || (fetchDataArray.count == 1 && self.sleepData.wakeUpTime > 0) ) {
        [userPreferences setBool:self.switchControl.on forKey:notificationName[5]];
        [self.intelligentNotification rescheduleIntelligentNotification];
    } else {
        [self dontHaveEnoughDataAlert];
    }
}

#pragma mark - alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.switchControl.on = NO;
}

#pragma mark - custom method

- (void)dontHaveEnoughDataAlert
{
    [[[UIAlertView alloc] initWithTitle:@"無法啟用"
                                message:@"資料不足，最少要有一筆完整的資料"
                               delegate:self
                      cancelButtonTitle:@"確定" otherButtonTitles:nil, nil] show];
}

- (void)updateSectionOneFooter
{
    remainingCounts = 1;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(countDown)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)countDown
{
    if (--remainingCounts == 0) {
        [timer invalidate];
        [self.tableView reloadData];
    }
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

@end
