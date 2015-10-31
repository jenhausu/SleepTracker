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
    
    selectedRow = [userPreferences integerForKey:@"醒來計時器計算方式"];
    awakeTime = @[@"照常計算", @"超過 24 小時便不再計算", @"減去 24 小時繼續計算", @"從「平均起床時間」開始計算"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"計算醒來時間"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return awakeTime.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = awakeTime[indexPath.row];
    cell.accessoryType = (indexPath.row == selectedRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
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
        [userPreferences setInteger:selectedRow forKey:@"醒來計時器計算方式"];
    }
}

@end
