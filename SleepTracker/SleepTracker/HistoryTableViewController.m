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
#import "IntelligentNotification.h"
#import "CustomNotification-Model.h"

@interface HistoryTableViewController ()

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, strong) NSArray *fetchDataArray;
@property (nonatomic, strong) SleepData *sleepData;

@property (nonatomic, strong) IntelligentNotification *intelligentNotification;

@property (nonatomic, strong) CustomNotification_Model *customNotification;

@end

@implementation HistoryTableViewController

@synthesize fetchDataArray;

#pragma mark - lazy initialization

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    
    return _sleepDataModel;
}

- (IntelligentNotification *)intelligentNotification
{
    if (!_intelligentNotification) {
        _intelligentNotification = [[IntelligentNotification alloc] init];
    }
    
    return _intelligentNotification;
}

- (CustomNotification_Model *)customNotification
{
    if (!_customNotification) {
        _customNotification = [[CustomNotification_Model alloc] init];
    }
    
    return _customNotification;
}

#pragma mark - view

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
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
    
    if (self.sleepData.wakeUpTime) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@",[dateFormatter stringFromDate:self.sleepData.goToBedTime], [dateFormatter2 stringFromDate:self.sleepData.wakeUpTime]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.sleepData.sleepType,[self stringFromTimeInterval:[self.sleepData.sleepTime floatValue]]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ ~",[dateFormatter stringFromDate:self.sleepData.goToBedTime]];
        cell.detailTextLabel.text = @" ";
    }

    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //刪除資料
        [self.sleepDataModel deleteSleepData:fetchDataArray[indexPath.row]];
        fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //重新設定睡前通知
        NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
        if (fetchDataArray.count) {
            self.sleepData = fetchDataArray[0];
            if (self.sleepData.wakeUpTime) {
                [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];
                [self.customNotification resetCustomNotification];
                [self.intelligentNotification rescheduleIntelligentNotification];
            } else {
                [userPreferences setValue:@"睡著" forKey:@"睡眠狀態"];
            }
        } else {
            [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];
            [self.customNotification resetCustomNotification];
            [self.intelligentNotification rescheduleIntelligentNotification];
        }
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
    NSInteger minutes = labs((time / 60) % 60);
    NSInteger hours = abs((int)(time / 3600));  //取整數
    
    if (time >= 0)
        return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
    else
        return [NSString stringWithFormat:@"-%02li:%02li", (long)hours, (long)minutes];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    self.sleepData = fetchDataArray[selectedIndexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/M/d EEE"];
    
    UITableViewController *page2 = segue.destinationViewController;
    if (self.sleepData.wakeUpTime) {
        page2.title = [dateFormatter stringFromDate:self.sleepData.wakeUpTime];
    } else {
        page2.title = [dateFormatter stringFromDate:self.sleepData.goToBedTime];
    }
    
    NSNumber *selectedRow = [NSNumber numberWithInteger:selectedIndexPath.row];
    [page2 setValue:selectedRow forKey:@"selectedRow"];
}


@end
