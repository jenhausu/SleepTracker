//
//  History2TableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "History2TableViewController.h"

#import "SleepDataModel.h"
#import "SleepData.h"

@interface History2TableViewController ()

@property (nonatomic, strong) NSArray *section1;
@property (nonatomic, strong) NSArray *section2;
@property (nonatomic, strong) NSArray *textLabelArray;

@property (nonatomic, strong) SleepDataModel *sleepDataModel;
@property (nonatomic, weak) NSArray *fetchDataArray;
@property (nonatomic, weak) SleepData *sleepData;
@property (weak) NSString *selectedRow;

@end

@implementation History2TableViewController

@synthesize section1, section2, fetchDataArray, selectedRow;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.sleepData = fetchDataArray[[selectedRow integerValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/M/d EEE ah:mm"];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [dateFormatter stringFromDate:self.sleepData.goToBedTime];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [dateFormatter stringFromDate:self.sleepData.wakeUpTime];
        }
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
        }
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
