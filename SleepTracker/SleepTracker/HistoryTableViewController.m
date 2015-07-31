//
//  HistoryTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/23.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "GoogleAnalytics.h"
#import <CloudKit/CloudKit.h>

#import "SleepDataModel.h"
#import "SleepData.h"

#import "SleepNotification.h"


@interface HistoryTableViewController ()

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, strong) NSArray *fetchDataArray;
@property (nonatomic, strong) SleepData *sleepData;

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

#pragma mark - view

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    /*
    // 刪除icloud上所有資料
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = [container privateCloudDatabase];
    NSString *recordType = @"SleepDataTest";
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:[NSPredicate predicateWithValue:YES]];
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            for (NSInteger i = 0 ; i < results.count ; i++ ) {
                CKRecord *record = results[i];
                [database deleteRecordWithID:record.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                    if (!error) {
                        
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
        } else {
            NSLog(@"fetch error:%@", error);
        }
    }];  //*/
    
    
    
    /*
    // 下載並寫入資料
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = [container privateCloudDatabase];
    NSString *recordType = @"SleepDataTest";
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:[NSPredicate predicateWithValue:YES]];
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"Seccessfullly fetch data, results.count:%d", (int)results.count);
            CKRecord *record;
            if (fetchDataArray.count != results.count) {
                for (NSInteger i = 0 ; i < results.count ; i++ ) {
                    record = results[i];
                    NSLog(@"recordID:%@", record.recordID);
                    [self.sleepDataModel addNewSleepdataAndAddGoToBedTime:[record valueForKey:@"GoToBedTime"]
                                                               wakeUpTime:[record valueForKey:@"WakeUpTime"]
                                                                sleepTime:[record valueForKey:@"SleepTime"]
                                                                sleepType:[record valueForKey:@"SleepType"]];
                }
                
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"fetch error:%@", error);
        }
    }];  //*/
    
    
    /*
    // 上傳最近十筆資料
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = [container privateCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"SleepDataTest" predicate:[NSPredicate predicateWithValue:YES]];
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"Seccessfullly fetch data, results.count:%d", (int)results.count);
            NSInteger count = (fetchDataArray.count);
            
            if (results.count != count) {  //
                for (NSInteger i = 0; i < 10 ; i++ ) {
                    self.sleepData = fetchDataArray[i];
     
                    NSString *recordName =[NSString stringWithFormat:@"%@", self.sleepData.goToBedTime];
                    CKRecordID *rocordID = [[CKRecordID alloc] initWithRecordName:recordName];
                    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"SleepDataTest" recordID:rocordID];
                    record[@"GoToBedTime"] = self.sleepData.goToBedTime;
                    record[@"WakeUpTime"] = self.sleepData.wakeUpTime;
                    record[@"SleepTime"] = self.sleepData.sleepTime;
                    record[@"SleepType"] = self.sleepData.sleepType;
                    NSLog(@"%@ %@", self.sleepData.goToBedTime, rocordID);
                    
                    [database saveRecord:record completionHandler:^(CKRecord *record, NSError *error){
                        if (!error) {
                            NSLog(@"Successfully save data %@", self.sleepData.goToBedTime);
                        } else {
                            NSLog(@"%@", error.localizedDescription);
                        }
                    }];
                }
            }
        } else {
            NSLog(@"fetch error:%@", error);
        }
    }];  //*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    fetchDataArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    [self.tableView reloadData];
    
    
    [self googleAnalytics];
}

- (void)googleAnalytics
{
    [[[GoogleAnalytics alloc] init] trackPageView:@"History"];
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
                [[[SleepNotification alloc] init] resetSleepNotification];
            } else {
                [userPreferences setValue:@"睡著" forKey:@"睡眠狀態"];
            }
        } else {
            [userPreferences setValue:@"清醒" forKey:@"睡眠狀態"];
            [[[SleepNotification alloc] init] resetSleepNotification];
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
