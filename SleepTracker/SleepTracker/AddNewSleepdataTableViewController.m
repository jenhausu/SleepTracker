//
//  AddNewSleepdataTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/30.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "AddNewSleepdataTableViewController.h"

#import "SleepDataModel.h"
#import "SleepData.h"
#import "IntelligentNotification.h"

@interface AddNewSleepdataTableViewController ()

@property (nonatomic, strong) NSArray *section1;
@property (nonatomic, strong) NSArray *section2;
@property (nonatomic, strong) NSArray *textLabel;

@property (nonatomic, weak) NSArray *fetchDataArray;
@property (nonatomic, weak) SleepData *sleepData;
@property (nonatomic, strong) NSDate *goToBedTime;
@property (nonatomic, strong) NSDate *wakeUpTime;
@property (strong, nonatomic) NSString *sleepType;
@property (assign, nonatomic) NSUInteger selectedSleepType;

@property (strong, nonatomic) IntelligentNotification *intelligentNotification;

@end

@implementation AddNewSleepdataTableViewController

@synthesize section1, section2, textLabel, goToBedTime, wakeUpTime, sleepType, selectedSleepType, fetchDataArray;

#pragma mark - lazy initialization

- (IntelligentNotification *)intelligentNotification
{
    if (!_intelligentNotification) {
        _intelligentNotification = [[IntelligentNotification alloc] init];
    }
    
    return _intelligentNotification;
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"上床時間", @"起床時間"];
    section2 = @[@"一般", @"小睡"];
    textLabel = @[section1, section2];
    
    [self setTitle:@"新增資料"];
    
    goToBedTime = [NSDate date];
    wakeUpTime = [NSDate date];
    selectedSleepType = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return textLabel.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [textLabel[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = textLabel[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/M/d EEE ah:mm"];
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

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewSleepdataTwo"];
        
        if (indexPath.row == 0)  {
            [page2 setValue:@"goToBedTime" forKey:@"DateType"];
        }
        else if (indexPath.row == 1)  {
            [page2 setValue:@"wakeUpTime" forKey:@"DateType"];
        }
        [page2 setValue:goToBedTime forKey:@"goToBedTime"];
        [page2 setValue:wakeUpTime forKey:@"wakeUpTime"];
        
        page2.title = self.textLabel[indexPath.section][indexPath.row];
        [page2 setValue:self forKey:@"addNewSleepdataOne"];
        
        [self.navigationController pushViewController:page2 animated:YES];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row != selectedSleepType)
        {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedSleepType inSection:1];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedSleepType = indexPath.row;
        }
    }
}

#pragma mark - button

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
    NSNumber *sleepTime = [NSNumber numberWithDouble:[wakeUpTime timeIntervalSinceDate:goToBedTime]];
    
    [[[SleepDataModel alloc] init] addNewSleepdataAndAddGoToBedTime:goToBedTime
                                                         wakeUpTime:wakeUpTime
                                                          sleepTime:sleepTime
                                                          sleepType:sleepType];
    
    [self.intelligentNotification rescheduleIntelligentNotification];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
