//
//  SettingTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/12.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SettingTableViewController.h"
#import "GoogleAnalytics.h"

#import <MessageUI/MessageUI.h>

#import "IntelligentNotification.h"

@interface SettingTableViewController ()  <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *setting;
@property (nonatomic) NSArray *zero;
@property (nonatomic) NSArray *music;

@property (nonatomic) NSUserDefaults *userPreferences;
@property (nonatomic) NSString *footerText;
@property (nonatomic) float footerHeight;
@property (nonatomic) NSInteger remainingCounts;
@property (nonatomic) NSTimer *timer;

@end

@implementation SettingTableViewController

@synthesize setting, zero, music;
@synthesize userPreferences, footerText, footerHeight, remainingCounts, timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setting = @[@[@"希望上床時間", @"計算醒來時間", @"「睡前通知」重複發出"],
                @[@"睡前播放音樂"],
                @[@"意見回饋"]];
    
    zero = @[@"照常計算", @"超過 24 小時不再計算", @"減去 24 小時", @"平均起床時間"];
    music = @[@"關閉", @"開啟"];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    
    [self googleAnalytics];
}

- (void)googleAnalytics
{
    [[[GoogleAnalytics alloc] init] trackPageView:@"Setting"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return setting.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [setting[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = setting[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:mm"];
            cell.detailTextLabel.text = [formatter stringFromDate:[[[IntelligentNotification alloc] init] decideShouldGoToBedTime]];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = ([userPreferences boolForKey:@"顯示醒了多久"]) ? zero[[userPreferences integerForKey:@"醒來計時器歸零"]] : @"不計算";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = @" ";
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
            cell.accessoryView = switchControl;
            switchControl.on = [userPreferences boolForKey:@"重複發出睡前通知"];
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = music[[userPreferences boolForKey:@"睡前播放音樂"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == (setting.count - 1)) {
        cell.detailTextLabel.text = @" ";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Footer

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
        CGRect rect = CGRectMake(20, 0, 280, 40);
        
        UIView *footerView = [[UIView alloc] initWithFrame:rect];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:rect];
        
        footerLabel.text = footerText;
        footerLabel.font = [UIFont systemFontOfSize:10];
        footerLabel.textColor = [UIColor lightTextColor];
        footerLabel.numberOfLines = 0;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        
        [footerView addSubview:footerLabel];
        return footerView;
    } else {
        return nil;
    }
}

#pragma mark - DidSelect

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *page2;
    
    if (indexPath.section == 0) {
        if (indexPath.row != 2) {
            page2 = (indexPath.row == 0) ? [self.storyboard instantiateViewControllerWithIdentifier:@"ShouldGoToSleepTime"]
                                         : [self.storyboard instantiateViewControllerWithIdentifier:@"AwakeTime"] ;
            page2.title = setting[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:page2 animated:YES];
        }
    } else if (indexPath.section == 1) {
        page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"MusicRoot"];
        page2.title = setting[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:page2 animated:YES];
    }  else if (indexPath.section == (setting.count - 1)) {
        if (indexPath.row == 0) {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                
                [mailViewController setToRecipients:[NSArray arrayWithObject:@"jenhausu@icloud.com"]];
                
                [self presentViewController:mailViewController animated:YES completion:NULL];
                [[[GoogleAnalytics alloc] init] trackPageView:@"Feedback"];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    UISwitch *switchControl = sender;
    [userPreferences setBool:switchControl.on forKey:@"重複發出睡前通知"];
    [[[IntelligentNotification alloc] init] rescheduleIntelligentNotification];
    
    if (switchControl.on) {
        footerText = @"如果前一天忘記輸入睡眠資料或是醒來超過24小時，到了晚上睡前通知要不要再次發出";
        footerHeight = 30;
        
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
    
    
    if (switchControl.on) {
        [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"前一天沒有輸入資料" action:@"睡前通知「要」重複發出" label:@"「睡前通知」重複發出" value:nil];
    } else {
        [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"前一天沒有輸入資料" action:@"睡前通知「不」重複發出" label:@"「睡前通知」重複發出" value:nil];
    }
}

- (void)postponeForAFewSecondThenChangeSectionOneFooter
{
    remainingCounts = 1;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                             target:self
                                           selector:@selector(countDown)
                                           userInfo:nil
                                            repeats:NO];
}

- (void)countDown
{
    if (--remainingCounts <= 0) {
        [timer invalidate];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
