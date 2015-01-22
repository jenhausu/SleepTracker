//
//  IntelligentNotificationTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "IntelligentNotificationTableViewController.h"

#import "IntelligentNotification.h"

@interface IntelligentNotificationTableViewController ()

@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *section3;

@end

@implementation IntelligentNotificationTableViewController

@synthesize array, section1, section2, section3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"Eat Food", @"Watch Electronic Screen", @"Take A Bath"];
    section2 = @[@"Average Go To Bed Time"];
    section3 = @[@"Awake for more than 16 hrs"];
    array = @[section1, section2, section3];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [array[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = array[indexPath.section][indexPath.row];

    return cell;
}


@end
