//
//  ShouldGoToSleepTimeTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/3/4.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "ShouldGoToSleepTimeTableViewController.h"

@interface ShouldGoToSleepTimeTableViewController ()

@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *textLabelOfTableViewCell;

@property (assign, nonatomic) NSUInteger selectedRow;

@end

@implementation ShouldGoToSleepTimeTableViewController

@synthesize section1, section2, textLabelOfTableViewCell, selectedRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"平均上床時間", @"平均起床時間"];
    section2 = @[@"自訂希望上床時間"];
    textLabelOfTableViewCell = @[section1, section2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    selectedRow = [userPreferences integerForKey:@"ShouldGoToSleepTime"];
    [self.tableView reloadData];
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
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = @"適合想要早點睡的人";
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = @"適合想要早點起床的人";
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
                        cell.detailTextLabel.text = [dateFormatter stringFromDate:localNotification.fireDate];
                        break;
                    }
                }
            } else {
                cell.detailTextLabel.text = @"--:--";
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
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if ([userPreferences integerForKey:@"ShouldGoToSleepTime"] == 2) {  //如果之前是選擇自訂希望上床時間，要把HopeToGoToBed的通知刪除
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
                    
                    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
                    oldCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    oldCell.detailTextLabel.text = @"--:--";
                                        
                    break;
                }
            }
        }
        
        [userPreferences setInteger:indexPath.row forKey:@"ShouldGoToSleepTime"];
        
        if (indexPath.row != selectedRow) {  //設定Checkmark
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedRow = indexPath.row;
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        CGRect rect = CGRectMake(20, 5, 280, 30);
        UIView *footerView = [[UIView alloc] initWithFrame:rect];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:rect];
        
        footerLabel.text = @"「希望起床時間」是App用來設定「吃東西」、「看電子螢幕」、「洗澡」這三個睡前通知的基準點。";
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

@end
