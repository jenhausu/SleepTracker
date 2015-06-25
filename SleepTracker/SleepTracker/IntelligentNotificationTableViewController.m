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
@property (nonatomic) float footerHeight;
@property (nonatomic) NSInteger selectedRow;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger remainingCounts;

@end

@implementation IntelligentNotificationTableViewController

@synthesize notificationName, fireDate, fetchDataArray, userPreferences, footerText, footerHeight, timer, remainingCounts;

#pragma mark - Lazy initialization

- (IntelligentNotification *)intelligentNotification
{
    if (!_intelligentNotification) {
        _intelligentNotification = [[IntelligentNotification alloc] init];
    }
    return _intelligentNotification;
}

#pragma mark - view

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.parentViewController.tabBarItem.title;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    fireDate = [self.intelligentNotification decideFireDate];
    notificationName = [self.intelligentNotification decideNotificationTitle];
    
    fetchDataArray = [[[SleepDataModel alloc] init] fetchSleepDataSortWithAscending:NO];
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
        return 3;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
        cell.accessoryView = switchControl;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0)
        {
            cell.textLabel.text = notificationName[indexPath.row];
            cell.detailTextLabel.text = [formatter stringFromDate:fireDate[indexPath.row]];
            
            switchControl.on = [userPreferences boolForKey:notificationName[indexPath.row]];
            
            if (indexPath.row == 0) {
                [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
            }
            else if (indexPath.row == 1) {
                [switchControl addTarget:self action:@selector(switchChanged2:) forControlEvents:UIControlEventValueChanged];
            }
            else if (indexPath.row == 2) {
                [switchControl addTarget:self action:@selector(switchChanged3:) forControlEvents:UIControlEventValueChanged];
            }
        } else if (indexPath.section == 1) {
            NSInteger sectionTwoRow = 3 + indexPath.row;
            cell.textLabel.text = notificationName[sectionTwoRow];
            if (fetchDataArray.count >= 2 || (fetchDataArray.count == 1 && self.sleepData.wakeUpTime > 0) ) {
                cell.detailTextLabel.text = [formatter stringFromDate:fireDate[sectionTwoRow]];
                
                if (indexPath.row == 1) {
                    if (!self.sleepData.wakeUpTime) {
                        cell.detailTextLabel.text = @"--:--";
                    }
                }
            } else {
                cell.detailTextLabel.text = @"--:--";
            }
            
            switchControl.on = [userPreferences boolForKey:notificationName[sectionTwoRow]];
            
            if (indexPath.row == 0) {
                [switchControl addTarget:self action:@selector(switchChanged4:) forControlEvents:UIControlEventValueChanged];
            } else if (indexPath.row == 1) {
                [switchControl addTarget:self action:@selector(switchChanged5:) forControlEvents:UIControlEventValueChanged];
            }
        }
        
        return cell;
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            
            cell2.textLabel.text = @"自訂睡前通知";
            cell2.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell2.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            return cell2;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return footerHeight;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        CGRect rect;
        if (self.selectedRow == 0 || self.selectedRow == 1) {
            rect = CGRectMake(20, 0, 280, 40);
        } else if (self.selectedRow == 3) {
            rect = CGRectMake(20, 0, 280, 35);
        } else {
            rect = CGRectMake(20, 0, 280, 50);
        }
        
        UIView *footerView = [[UIView alloc] initWithFrame:rect];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:rect];
        
        footerLabel.text = footerText;
        footerLabel.font = [UIFont fontWithName:@"AppleGothic" size:10];
        footerLabel.textColor = [UIColor lightTextColor];
        footerLabel.numberOfLines = 0;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        
        [footerView addSubview:footerLabel];
        return footerView;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomNotification"];
        page2.title = @"自訂睡前通知";
        
        [self.navigationController pushViewController:page2 animated:YES];
    }
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[0]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    //設定說明文字
    if (self.switchControl.on) {
        footerText = @"App 會在希望上床睡覺時間的前三個小時發出通知，提醒你不要再吃東西了，好讓腸胃開始休息。";
        footerHeight = 35;
        
        self.selectedRow = 0;
        
        [self postponeForAFewSecondThenChangeSectionOneFooter];
    } else {
        if (footerText) {
            footerText = nil;
            footerHeight = 0;
            
            [self postponeForAFewSecondThenChangeSectionOneFooter];
        } else {
            footerText = nil;
            footerHeight = 0;
        }
    }
}

- (void)switchChanged2:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[1]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    //設定說明文字
    if (self.switchControl.on) {
        footerText = @"App 會在希望上床睡覺時間的前一個小時發出通知，提醒你不要再看電子螢幕了。";
        footerHeight = 35;
        
        self.selectedRow = 1;
        
        [self postponeForAFewSecondThenChangeSectionOneFooter];
    } else {
        if (footerText) {
            footerText = nil;
            footerHeight = 0;
            
            [self postponeForAFewSecondThenChangeSectionOneFooter];
        } else {
            footerText = nil;
            footerHeight = 0;
        }
    }
}

- (void)switchChanged3:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[2]];
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    //設定說明文字
    if (self.switchControl.on) {
        footerText = @"App 會在希望上床睡覺時間的前兩個小時發出通知，提醒你如果你還沒去洗澡，建議你可以去洗個澡，這樣兩個小時後體溫開始下降，最適合入睡。";
        footerHeight = 45;
        
        self.selectedRow = 2;
        
        [self postponeForAFewSecondThenChangeSectionOneFooter];
    } else {
        if (footerText) {
            footerText = nil;
            footerHeight = 0;
            
            [self postponeForAFewSecondThenChangeSectionOneFooter];
        } else {
            footerText = nil;
            footerHeight = 0;
        }
    }
}

- (void)switchChanged4:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[3]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

- (void)switchChanged5:(id)sender
{
    self.switchControl = sender;
    [userPreferences setBool:self.switchControl.on forKey:notificationName[4]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

#pragma mark - custom method

- (void)postponeForAFewSecondThenChangeSectionOneFooter
{
    remainingCounts = 1;
    [NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(countDown)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)countDown
{
    if (--remainingCounts <= 0) {
        [timer invalidate];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.switchControl setOn:NO animated:YES];
}

@end
