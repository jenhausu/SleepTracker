//
//  AddNewSleepdataTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/30.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "AddNewSleepdataTableViewController.h"

@interface AddNewSleepdataTableViewController ()

@property (nonatomic, strong) NSArray *section1;
@property (nonatomic, strong) NSArray *section2;
@property (nonatomic, strong) NSArray *textLabel;

@end

@implementation AddNewSleepdataTableViewController

@synthesize section1, section2, textLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"上床時間", @"起床時間"];
    section2 = @[@"一般", @"小睡"];
    textLabel = @[section1, section2];
    
    [self setTitle:@"新增資料"];
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
    
    return cell;
}

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
    
    self.sleepDataModel = [[SleepDataModel alloc] init];
    [self.sleepDataModel addNewSleepdataAndAddGoToBedTime:goToBedTime
                                               wakeUpTime:wakeUpTime
                                                sleepTime:sleepTime
                                                sleepType:sleepType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
