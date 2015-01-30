//
//  HistoryTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/23.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "HistoryTableViewController.h"

#import "SleepDataModel.h"
#import "SleepData.h"

@interface HistoryTableViewController ()

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, strong) NSArray *fetchDataArray;
@property (nonatomic, strong) SleepData *sleepData;

@end

@implementation HistoryTableViewController

@synthesize fetchDataArray;

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    
    return _sleepDataModel;
}

- (void)viewWillAppear:(BOOL)animated
{
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fetchDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    self.sleepData = fetchDataArray[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/M/d ah:mm";
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy/M/d EEE ah:mm"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@",[dateFormatter stringFromDate:self.sleepData.goToBedTime], [dateFormatter2 stringFromDate:self.sleepData.wakeUpTime]];
    
    NSDateFormatter *dateFormatter5 = [[NSDateFormatter alloc] init];
    [dateFormatter5 setDateFormat:@"DDD"];
    NSInteger day = [[dateFormatter5 stringFromDate:self.sleepData.wakeUpTime] integerValue];
    if (day % 2 == 0) {
        cell.textLabel.textColor = [UIColor colorWithRed:0.267 green:0.486 blue:0.843 alpha:1] /*#447cd7*/;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.sleepData.sleepType,[self stringFromTimeInterval:[self.sleepData.sleepTime floatValue]]];

    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.sleepDataModel deleteSleepData:fetchDataArray[indexPath.row]];
        fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - add 

- (IBAction)addNewSleepdata:(id)sender
{
    UINavigationController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewSleepData"];
    [self presentViewController:page2 animated:YES completion:nil];
}

#pragma mark - Custom Method

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger time = (NSInteger)interval;
    NSInteger minutes = abs((time / 60) % 60);
    NSInteger hours = abs((int)(time / 3600));  //取整數
    
    if (time >= 0)
        return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
    else
        return [NSString stringWithFormat:@"-%02li:%02li", (long)hours, (long)minutes];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewController *page2 = segue.destinationViewController;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    self.sleepData = fetchDataArray[selectedIndexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/M/d EEE"];
    
    page2.title = [dateFormatter stringFromDate:self.sleepData.wakeUpTime];
    
    
    NSNumber *selectedRow = [NSNumber numberWithInteger:selectedIndexPath.row];
    [page2 setValue:selectedRow forKey:@"selectedRow"];
}


@end
