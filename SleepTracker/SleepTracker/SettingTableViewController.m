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

#import "ZeroTableViewCell.h"

@interface SettingTableViewController ()  <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *setting;
@property (nonatomic) NSArray *zero;

@property (nonatomic) NSUserDefaults *userPreferences;
@property (nonatomic) NSString *footerText;
@property (nonatomic) float footerHeight;
@property (nonatomic) NSInteger remainingCounts;
@property (nonatomic) NSTimer *timer;

@end

@implementation SettingTableViewController

@synthesize setting, zero;
@synthesize userPreferences, footerText, footerHeight, remainingCounts, timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setting = @[@[@"希望上床時間"],
                @[@"「睡前通知」重複發出", @"計算醒來時間"],
                @[@"意見回饋"]];
    
    zero = @[@"照常計算", @"不再計算", @"減去 24 小時", @"平均起床時間"];
    
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
    if (indexPath.section != 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.textLabel.text = setting[indexPath.section][indexPath.row];
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                cell.detailTextLabel.text = [formatter stringFromDate:[[[IntelligentNotification alloc] init] decideShouldGoToBedTime]];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.accessoryView = nil;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        } else if (indexPath.section == (setting.count - 1)) {
            cell.detailTextLabel.text = @" ";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    } else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            
            cell.textLabel.text = setting[indexPath.section][indexPath.row];
            cell.detailTextLabel.text = @" ";
            
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
            cell.accessoryView = switchControl;
            switchControl.on = [userPreferences boolForKey:@"重複發出睡前通知"];
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } else if (indexPath.row == 1) {
            ZeroTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            
            cell2.text.text = setting[indexPath.section][indexPath.row];
            cell2.detailText.text = zero[[userPreferences integerForKey:@"醒來計時器歸零"]];
            cell2.detailText.font = [UIFont systemFontOfSize:15];
            
            cell2.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell2;
        }
    }
    
    return nil;
}

#pragma mark - Header

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"前一天沒有輸入資料";
    } else {
        return nil;
    }
}

/*
 
#define HeadersHeight 28

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect;
    UILabel *headerLabel;
    
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        rect = CGRectMake(15, 3, 280, HeadersHeight);
        headerLabel = [[UILabel alloc] initWithFrame:rect];
        
        headerLabel.text = @"前一天沒有輸入資料";
        
        headerLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.numberOfLines = 0;
        headerLabel.textAlignment = NSTextAlignmentLeft;
        
        UIView *headerView = [[UIView alloc] initWithFrame:rect];
        [headerView addSubview:headerLabel];
        return headerView;
    } else {
        return nil;
    }
    

}  //*/
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *page2;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ShouldGoToSleepTime"];
            page2.title = setting[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:page2 animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"zero"];
            page2.title = setting[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:page2 animated:YES];
        }
    } else if (indexPath.section == (setting.count - 1)) {
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
        [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"前一天沒有輸入資料" action:@"睡前通知「要」重複發出" label:@"「睡前通知」重複發出" value:nil];
    } else {
        [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"前一天沒有輸入資料" action:@"睡前通知「不」重複發出" label:@"「睡前通知」重複發出" value:nil];
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
