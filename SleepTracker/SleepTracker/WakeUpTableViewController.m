//
//  WakeUpTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/24.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "WakeUpTableViewController.h"

#import "SleepDataModel.h"
#import "SleepData.h"

@interface WakeUpTableViewController ()

@property (weak) id<save> delegate;

@property (nonatomic, strong) NSArray *section1;
@property (nonatomic, strong) NSArray *section2;
@property (nonatomic, strong) NSArray *textLabelArray;
@property (assign, nonatomic) NSUInteger selectedSleepType;
@property (strong, nonatomic) NSString *sleepType;

@property (strong, nonatomic) NSDate *goToBedTime;
@property (strong, nonatomic) NSDate *wakeUpTime;

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, weak) NSArray *fetchDataArray;
@property (nonatomic, weak) SleepData *sleepData;

@end

@implementation WakeUpTableViewController

@synthesize delegate, section1, section2, fetchDataArray, selectedSleepType, sleepType, goToBedTime, wakeUpTime;

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    
    return _sleepDataModel;
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"上床時間", @"起床時間"];
    section2 = @[@"一般", @"小睡"];
    self.textLabelArray = @[section1, section2];
    
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    self.sleepData = fetchDataArray[0];
    
    goToBedTime = self.sleepData.goToBedTime;
    wakeUpTime = [NSDate date];
    selectedSleepType = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/M/d EEE"];
    self.title = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.textLabelArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.textLabelArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.textLabelArray[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ah:mm"];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [dateFormatter stringFromDate:goToBedTime];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [dateFormatter stringFromDate:wakeUpTime];
        }
    } else if (indexPath.section == 1) {
        cell.detailTextLabel.text = @"";
        
        if (indexPath.row == selectedSleepType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"wakeUp2"];
        
        if (indexPath.row == 0)  [page2 setValue:@"goToBedTime" forKey:@"DateType"];
        else if (indexPath.row == 1)  [page2 setValue:@"wakeUpTime" forKey:@"DateType"];
        [page2 setValue:goToBedTime forKey:@"goToBedTime"];
        [page2 setValue:wakeUpTime forKey:@"wakeUpTime"];
        
        [page2 setValue:self forKey:@"wakeUpViewController"];
        page2.title = self.textLabelArray[indexPath.section][indexPath.row];
        
        [self.navigationController pushViewController:page2 animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row != selectedSleepType) {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedSleepType inSection:1];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedSleepType = indexPath.row;
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Custom Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return UITableViewAutomaticDimension;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        CGRect rect = CGRectMake(20, 0, 280, 35);
        UIView *footerView = [[UIView alloc] initWithFrame:rect];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:rect];
        
        if (selectedSleepType == 0) {
            footerLabel.text = @"App 在計算起床時間、上床時間時，只會讀取「一般」睡眠型態的資料。";  //如果一天有好幾筆一般睡眠型態的資料，App 會取這一天全部的「一般」睡眠型態的頭跟尾，來當作這天的上床跟起床時間做計算。
        } else if (selectedSleepType == 1) {
            footerLabel.text = @"「小睡」睡眠型態的資料只有在 App 計算「睡覺時間」時才會一起納入計算。";
        }
        
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

#pragma mark - navigation button

- (IBAction)save:(id)sender
{
    switch (selectedSleepType) {
        case 0:
            sleepType = @"一般";
            break;
        case 1:
            sleepType = @"小睡";
            break;
    }
    
    NSInteger const LATEST_DATA = 0;
    NSNumber *sleepTime = [NSNumber numberWithFloat:[wakeUpTime timeIntervalSinceDate:goToBedTime]];
    [self.sleepDataModel updateAllSleepdataInRow:LATEST_DATA
                                     goToBedTime:goToBedTime
                                      wakeUpTime:wakeUpTime
                                       sleepTime:sleepTime
                                       sleepType:sleepType];
    
    [delegate saveButtonPress];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
