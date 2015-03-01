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

@property (strong, nonatomic) IntelligentNotification *intelligentNotification;
@property (strong, nonatomic) NSArray *fireDate;
@property (strong, nonatomic) NSArray *notificationName;

@end

@implementation IntelligentNotificationTableViewController

@synthesize notificationName, fireDate;

#pragma mark - Lazy initialization

- (IntelligentNotification *)intelligentNotification
{
    if (!_intelligentNotification) {
        _intelligentNotification = [[IntelligentNotification alloc] init];
    }
    return _intelligentNotification;
}

#pragma mark - view

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    fireDate = [self.intelligentNotification decideFireDate];
    notificationName = [self.intelligentNotification decideNotificationTitle];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = notificationName[indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = notificationName[3];
    } else {
        cell.textLabel.text = notificationName[4];
    }
    cell.detailTextLabel.text = [formatter stringFromDate:fireDate[indexPath.row]];

    UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
    cell.accessoryView = switchControl;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0)
    {
        switchControl.on = [userPreferences boolForKey:notificationName[indexPath.row]];
        cell.detailTextLabel.text = [formatter stringFromDate:fireDate[indexPath.row]];

        if (indexPath.row == 0) {
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
        }
        else if (indexPath.row == 1) {
            [switchControl addTarget:self action:@selector(switchChanged2:) forControlEvents:UIControlEventValueChanged];
        }
        else if (indexPath.row == 2) {
            [switchControl addTarget:self action:@selector(switchChanged3:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else if (indexPath.section == 1) {
        cell.detailTextLabel.text = [formatter stringFromDate:fireDate[3]];

        if (indexPath.row == 0) {
            switchControl.on = [userPreferences boolForKey:notificationName[3]];
            [switchControl addTarget:self action:@selector(switchChanged4:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else if (indexPath.section == 2) {
        cell.detailTextLabel.text = [formatter stringFromDate:fireDate[4]];

        switchControl.on = [userPreferences boolForKey:notificationName[4]];
        [switchControl addTarget:self action:@selector(switchChanged5:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:notificationName[0]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

- (void)switchChanged2:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:notificationName[1]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

- (void)switchChanged3:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:notificationName[2]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

- (void)switchChanged4:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:notificationName[3]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

- (void)switchChanged5:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:notificationName[4]];
    [self.intelligentNotification rescheduleIntelligentNotification];
}

@end
