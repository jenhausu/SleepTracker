//
//  ZeroTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/6/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "ZeroTableViewController.h"

@interface ZeroTableViewController ()

@property (nonatomic) NSArray *zero;

@property (nonatomic) NSUserDefaults *userPreferences;
@property (assign, nonatomic) NSUInteger selectedRow;

@end

@implementation ZeroTableViewController

@synthesize zero, userPreferences, selectedRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    zero = @[@[@"照常計算", @"超過 24 小時便不再計算"], @[@"減去 24 小時繼續計算", @"從平均起床時間開始計算"]];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    selectedRow = [userPreferences integerForKey:@"醒來計時器歸零"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return zero.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [zero[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = zero[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        if (selectedRow == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 1) {
        if ((selectedRow - 2) == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (selectedRow == 0 || selectedRow == 1) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    } else if (selectedRow == 2 || selectedRow == 3) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedRow - 2 inSection:1];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    if (indexPath.section == 0) {
        selectedRow = indexPath.row;
    } else if (indexPath.section == 1) {
        selectedRow = indexPath.row + 2;
    }
    
    [userPreferences setInteger:selectedRow forKey:@"醒來計時器歸零"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"普通";
    } else {
        return @"智能";
    }
}

- (NSString * )tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return @"如果選擇智能計算醒來的時間，就算你忘記紀錄睡眠時間，App 會根據過去的資料推算你現在大概醒了多久。";  //醒來
    } else {
        return nil;
    }
}

@end
