//
//  SettingTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/12.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SettingTableViewController.h"
#import "GoogleAnalytics.h"
#import "Mixpanel_Model.h"

#import <MessageUI/MessageUI.h>

#import "IntelligentNotification.h"
#import "SleepDataModel.h"

@interface SettingTableViewController ()  <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *setting;
@property (nonatomic) NSArray *zero;

@property (nonatomic) NSUserDefaults *userPreferences;
@property (nonatomic) NSString *footerText;
@property (nonatomic) float footerHeight;
@property (nonatomic) NSInteger remainingCounts;
@property (nonatomic) NSTimer *timer;

@property (nonatomic) SleepDataModel *sleepDataModel;

@end

@implementation SettingTableViewController

@synthesize setting, zero;
@synthesize userPreferences, footerText, footerHeight, remainingCounts, timer;

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc]init];
    }
    return _sleepDataModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setting = @[@[@"希望上床時間"],
                @[@"計算醒來時間", @"「睡前通知」繼續發出"],
                @[@"刪除所有睡眠資料"],
                @[[NSString stringWithFormat:@"%@ 版 新功能說明", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]], @"寫信給開發者"]];
    
    zero = @[@"照常計算", @"超過 24 小時不再計算", @"減去 24 小時", @"平均起床時間"];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    
    
    [[[Mixpanel_Model alloc] init] trackEvent:@"查看「設定」頁面" key:@"view" value:@"viewDidLoad"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"Setting"];
    [[[Mixpanel_Model alloc] init] trackEvent:@"查看「設定」頁面" key:@"view" value:@"viewWillAppear"];
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
            formatter.dateFormat = @"HH:mm";
            
            cell.detailTextLabel.text = [formatter stringFromDate:[[[IntelligentNotification alloc] init] decideShouldGoToBedTime]];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [userPreferences boolForKey:@"顯示醒了多久"] ? zero[[userPreferences integerForKey:@"醒來計時器歸零"]] : @"關閉" ;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = @" ";
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
            cell.accessoryView = switchControl;
            switchControl.on = [userPreferences boolForKey:@"重複發出睡前通知"];
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else if (indexPath.section == 2) {
        cell.detailTextLabel.text = @" ";
    } else if (indexPath.section == (setting.count - 1)) {
        cell.detailTextLabel.text = @" ";
        
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    
    return cell;
}

#pragma mark - Header

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"前一天沒有輸入資料時";
    } else if (section == 2) {
        return @"刪除資料";
    } else if (section == 3) {
        return @"其它";
    } else {
        return nil;
    }
}

#pragma mark - Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return footerHeight;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
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

#pragma mark - didSelected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self pushViewController:@"ShouldGoToSleepTime" section:indexPath.section row:indexPath.row];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self pushViewController:@"AwakeTime" section:indexPath.section row:indexPath.row];
        }
    } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"刪除所有睡眠資料"
                                                                message:@"刪除後所有資料都無法復原，你確定要刪除所有睡眠資料？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"確定", nil];
                [alert show];
            }
    } else if (indexPath.section == (setting.count - 1)) {
        if (indexPath.row == 0) {
            NSString *title = [NSString stringWithFormat:@"%@ 版 新功能", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:@"1. 現在只要把通知往左滑就會有「稍後通知」、「我要熬夜」的選項了。\n2. 使用者可以決定要不要計算醒來時間。"
                                                           delegate:self
                                                  cancelButtonTitle:@"確定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            [[[GoogleAnalytics alloc] init] trackPageView:@"New Feature Instruction"];
            [[[Mixpanel_Model alloc] init] trackEvent:@"查看「新功能說明」" key:@"" value:@""];
        } else if (indexPath.row == [setting[indexPath.section] count] - 1) {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                
                [mailViewController setToRecipients:[NSArray arrayWithObject:@"jenhausu@icloud.com"]];
                [mailViewController setSubject:@"意見回饋"];
                
                [self presentViewController:mailViewController animated:YES completion:NULL];
                [[[GoogleAnalytics alloc] init] trackPageView:@"Feedback"];
                [[[Mixpanel_Model alloc] init] trackEvent:@"點選「寫信給開發者」" key:@"狀態" value:@"成功"];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [[[Mixpanel_Model alloc] init] trackEvent:@"點選「寫信給開發者」" key:@"狀態" value:@"失敗"];
            }
        }
    }
}

- (void)pushViewController:(NSString *)identifier section:(NSInteger)section row:(NSInteger)row
{
    UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    page2.title = setting[section][row];
    [self.navigationController pushViewController:page2 animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"刪除所有睡眠資料"]) {
        if (buttonIndex == 1) {
            NSArray *fetchData = [self.sleepDataModel fetchSleepDataSortWithAscending:YES];
            for (NSInteger i = 0 ; i < fetchData.count ; i++ ) {
                [self.sleepDataModel deleteSleepData:fetchData[i]];
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
        }
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
