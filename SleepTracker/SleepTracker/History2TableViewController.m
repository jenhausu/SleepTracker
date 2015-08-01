//
//  History2TableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "History2TableViewController.h"
#import "GoogleAnalytics.h"

#import "SleepDataModel.h"
#import "SleepData.h"

#import "SleepNotification.h"

@interface History2TableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *section1;
@property (nonatomic, strong) NSArray *section2;
@property (nonatomic, strong) NSArray *textLabelArray;

@property (strong, nonatomic) NSNumber *selectedRow;

@property (strong, nonatomic) NSDate *goToBedTime;
@property (strong, nonatomic) NSDate *wakeUpTime;

@property (strong, nonatomic) NSString *sleepType;
@property (assign, nonatomic) NSUInteger selectedSleepType;

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, weak) NSArray *fetchDataArray;
@property (nonatomic, weak) SleepData *sleepData;

@end

@implementation History2TableViewController

@synthesize section1, section2, textLabelArray, fetchDataArray, selectedRow, goToBedTime, wakeUpTime, sleepType, selectedSleepType;

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    
    return _sleepDataModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"上床時間", @"起床時間"];
    section2 = @[@"一般", @"小睡"];
    self.textLabelArray = @[section1, section2];
    
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    self.sleepData = fetchDataArray[[selectedRow integerValue]];
    goToBedTime = self.sleepData.goToBedTime;
    wakeUpTime = self.sleepData.wakeUpTime;
    
    if (!wakeUpTime) {  //如果沒有起床時間的話
        wakeUpTime = [NSDate date];
    }
    
    if ([self.sleepData.sleepType isEqualToString:@"一般"]) {
        selectedSleepType = 0;
    } else if ([self.sleepData.sleepType isEqualToString:@"小睡"]) {
        selectedSleepType = 1;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [self.tableView reloadData];
    
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"History Detail"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.textLabelArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.textLabelArray[indexPath.section][indexPath.row];
    
    
    if (indexPath.section == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ah:mm"];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [dateFormatter stringFromDate:goToBedTime];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [dateFormatter stringFromDate:wakeUpTime];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1) {
        cell.detailTextLabel.text = @"";
        
        if (indexPath.row == selectedSleepType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"History3"];
        
        if (indexPath.row == 0)  [page2 setValue:@"goToBedTime" forKey:@"DateType"];
        else if (indexPath.row == 1)  [page2 setValue:@"wakeUpTime" forKey:@"DateType"];
        [page2 setValue:goToBedTime forKey:@"goToBedTime"];
        [page2 setValue:wakeUpTime forKey:@"wakeUpTime"];
        [page2 setValue:selectedRow forKey:@"selectedRow"];
        
        page2.title = self.textLabelArray[indexPath.section][indexPath.row];
        [page2 setValue:self forKey:@"History2ViewController"];
        
        [self.navigationController pushViewController:page2 animated:YES];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row != selectedSleepType) {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedSleepType inSection:1];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedSleepType = indexPath.row;
        }
    }
}

#pragma mark - Custom Method

- (IBAction)update:(id)sender {
    switch (selectedSleepType) {
        case 0:
            sleepType = @"一般";
            break;
        case 1:
            sleepType = @"小睡";
            break;
    }
    
    NSNumber *sleepTime = [NSNumber numberWithDouble:[wakeUpTime timeIntervalSinceDate:goToBedTime]];
    [self.sleepDataModel updateAllSleepdataInRow:[selectedRow integerValue]
                                     goToBedTime:goToBedTime
                                      wakeUpTime:wakeUpTime
                                       sleepTime:sleepTime
                                       sleepType:sleepType];
    
    NSUserDefaults *userPreferences = userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];
    [[[SleepNotification alloc] init] resetSleepNotification];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改資料"
                                                    message:@"成功！"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"確定", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
