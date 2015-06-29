//
//  ShouldGoToSleepTimeTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/3/4.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "ShouldGoToSleepTimeTableViewController.h"
#import "GoogleAnalytics.h"

#import "IntelligentNotification.h"
#import "Statistic.h"

@interface ShouldGoToSleepTimeTableViewController ()

@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *textLabelOfTableViewCell;
@property (nonatomic) NSArray *fireDate;
@property (assign, nonatomic) NSUInteger selectedRow;
@property (nonatomic) NSString *footerText;

@property (nonatomic) NSUserDefaults *userPreferences;

@end

@implementation ShouldGoToSleepTimeTableViewController

@synthesize section1, section2, textLabelOfTableViewCell, fireDate, selectedRow, footerText, userPreferences;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"平均上床時間", @"平均起床時間"];
    section2 = @[@"自訂希望上床時間"];
    textLabelOfTableViewCell = @[section1, section2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    selectedRow = [userPreferences integerForKey:@"ShouldGoToSleepTime"];
    
    if (footerText) footerText = nil;
    
    [self.tableView reloadData];
    
    
    [self googleAnalytics];
}

- (void)googleAnalytics
{
    [[[GoogleAnalytics alloc] init] trackPageView:@"ShouldGoToBedTime"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [textLabelOfTableViewCell count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [textLabelOfTableViewCell[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = textLabelOfTableViewCell[indexPath.section][indexPath.row];
    cell.detailTextLabel.text = @"--:--";
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            
            NSInteger averageGoToSleepTimeInSecond = [[[[[Statistic alloc] init] showGoToBedTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
            if (averageGoToSleepTimeInSecond) {
                dateComponents.hour = averageGoToSleepTimeInSecond / 3600;
                dateComponents.minute = ((averageGoToSleepTimeInSecond / 60) % 60);
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                cell.detailTextLabel.text = [dateFormatter stringFromDate:[greCalendar dateFromComponents:dateComponents]];  //@"適合想要早點睡的人";
            }
        } else if (indexPath.row == 1) {
            NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            
            NSInteger averageWakeUpTimeInSecond = [[[[[Statistic alloc] init] showWakeUpTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
            if (averageWakeUpTimeInSecond) {
                dateComponents.hour = ((averageWakeUpTimeInSecond / 3600  - 8) >= 0) ? (averageWakeUpTimeInSecond / 3600 - 8) : (averageWakeUpTimeInSecond / 3600 - 8) + 24 ;
                dateComponents.minute = ((averageWakeUpTimeInSecond / 60) % 60);

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                cell.detailTextLabel.text = [dateFormatter stringFromDate:[greCalendar dateFromComponents:dateComponents]];  //@"適合想要早點睡的人";
            }
        }
        
        if (indexPath.row == selectedRow) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (selectedRow == 2) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                cell.detailTextLabel.text = [dateFormatter stringFromDate: [userPreferences valueForKey:@"HopeToGoToBedTime"]];
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    
    return cell;
}

#pragma mark - tableView 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        // 如果之前是選擇自訂希望上床時間，要先把HopeToGoToBed的通知刪除
        if ([userPreferences integerForKey:@"ShouldGoToSleepTime"] == 2)
        {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            oldCell.detailTextLabel.text = @"--:--";
        }
        
        // 設定 ShouldGoToSleepTime
        [userPreferences setInteger:indexPath.row forKey:@"ShouldGoToSleepTime"];
        
        
        // 設定Checkmark
        if (indexPath.row != selectedRow) {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedRow = indexPath.row;
            
            [[[IntelligentNotification alloc] init] rescheduleIntelligentNotification];
        }
        
        // 設定 Footer
        if (indexPath.row == 1) {
            footerText = @"選擇平均起床時間，App會把「平均起床時間」往前推 8 個小時作為希望起床時間。";
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            if (footerText) {
                footerText = nil;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [userPreferences setInteger:2 forKey:@"ShouldGoToSleepTime"];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"HopeToGoToBedPage"];
            page2.title = textLabelOfTableViewCell[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:page2 animated:YES];
        }
    }
}

#pragma mark - Footer

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return footerText;
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        CGRect rect = CGRectMake(20, 5, 280, 30);
        UIView *footerView = [[UIView alloc] initWithFrame:rect];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:rect];
        
        footerLabel.text = @"希望起床時間是App用來設定「吃東西」、「看電子螢幕」、「洗澡」這三個睡前通知的基準點。";
        footerLabel.font = [UIFont fontWithName:@"AppleGothic" size:11];
        footerLabel.textColor = [UIColor grayColor];
        footerLabel.numberOfLines = 0;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        
        [footerView addSubview:footerLabel];
        return footerView;
    } else {
        return nil;
    }
}

#pragma mark -

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        switch ([userPreferences integerForKey:@"ShouldGoToSleepTime"]) {
            case 0:
                [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"希望上床時間" action:@"平均「上床」時間" label:@"智能" value:nil];
                break;
            case 1:
                [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"希望上床時間" action:@"平均「起床」時間" label:@"智能" value:nil];
                break;
            case 2:
                [[[GoogleAnalytics alloc] init] trackEventWithCategory:@"希望上床時間" action:@"自訂" label:@"自訂" value:nil];
                break;
        }
    }
}

@end
