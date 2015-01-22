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

@property (strong, nonatomic) IntelligentNotification *intelligentNotification;
@property (strong, nonatomic) NSArray *fireTime;

@end

@implementation IntelligentNotificationTableViewController

@synthesize array, section1, section2, section3, fireTime;

#pragma mark - Lazy initialization

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
    
    section1 = @[@"Eat Food", @"Watch Electronic Screen", @"Take A Bath"];
    section2 = @[@"Average Go To Bed Time"];
    section3 = @[@"awake for more than 16 hrs"];
    array = @[section1, section2, section3];
    
    fireTime = [self.intelligentNotification decideFireTime];
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    cell.textLabel.text = array[indexPath.section][indexPath.row];
    cell.detailTextLabel.text = [formatter stringFromDate:fireTime[indexPath.row]];

    UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
    cell.accessoryView = switchControl;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0)
    {
        switchControl.on = [userPreferences boolForKey:section1[indexPath.row]];
        
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
        if (indexPath.row == 0) {
            switchControl.on = [userPreferences boolForKey:section2[indexPath.row]];
            [switchControl addTarget:self action:@selector(switchChanged4:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else if (indexPath.section == 2) {
        switchControl.on = [userPreferences boolForKey:section3[indexPath.row]];
        [switchControl addTarget:self action:@selector(switchChanged5:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:section1[0]];
}

- (void)switchChanged2:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:section1[1]];
}

- (void)switchChanged3:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:section1[2]];
}

- (void)switchChanged4:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:section2[0]];
}

- (void)switchChanged5:(id)sender
{
    UISwitch *switchControl = sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:switchControl.on forKey:section3[0]];
}

@end
