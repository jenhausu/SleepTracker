//
//  AwakeTimeTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/7/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "AwakeTimeTableViewController.h"
#import "GoogleAnalytics.h"

@interface AwakeTimeTableViewController ()

@property (nonatomic) NSUserDefaults *userPreferences;

@property (nonatomic) NSArray *awakeTime;
@property (nonatomic) NSArray *switcher;
@property (nonatomic) NSArray *after24h;

@property (assign, nonatomic) NSUInteger selectedRow;

@end

@implementation AwakeTimeTableViewController

@synthesize awakeTime, userPreferences, selectedRow, after24h, switcher;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userPreferences =  [NSUserDefaults standardUserDefaults];
    
    
    selectedRow = [userPreferences integerForKey:@"醒來計時器歸零"];
    
    switcher = @[@"計算今天醒了多久"];
    after24h = @[@"照常計算", @"超過 24 小時便不再計算", @"減去 24 小時繼續計算", @"從「平均起床時間」開始計算"];
    awakeTime = ([userPreferences boolForKey:@"顯示醒了多久"]) ? @[switcher, after24h] : @[switcher] ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"計算醒來時間"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return awakeTime.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [awakeTime[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = awakeTime[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
            cell.accessoryView = switchControl;
            switchControl.on = [userPreferences boolForKey:@"顯示醒了多久"];
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == selectedRow) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // 原本選擇的 row
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:indexPath.section];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        // 新選擇的 row
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // 設定新的選擇
        selectedRow = indexPath.row;
        [userPreferences setInteger:selectedRow forKey:@"醒來計時器歸零"];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"如果前一天沒有輸入資料";
    } else {
        return nil;
    }
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    UISwitch *switchControl = sender;
    [userPreferences setBool:switchControl.on forKey:@"顯示醒了多久"];
    
    [self.tableView beginUpdates];
    if ([userPreferences boolForKey:@"顯示醒了多久"]) {
        awakeTime = @[switcher, after24h];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        awakeTime = @[switcher];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

@end
