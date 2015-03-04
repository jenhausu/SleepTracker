//
//  ShouldGoToSleepTimeTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/3/4.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "ShouldGoToSleepTimeTableViewController.h"

@interface ShouldGoToSleepTimeTableViewController ()

@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *textLabelOfTableViewCell;

@end

@implementation ShouldGoToSleepTimeTableViewController

@synthesize section1, section2, textLabelOfTableViewCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"平均上床時間", @"平均起床時間"];
    section2 = @[@"自訂希望上床時間"];
    
    
    textLabelOfTableViewCell = @[section1, section2];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [textLabelOfTableViewCell count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [textLabelOfTableViewCell[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = textLabelOfTableViewCell[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = @"適合想要早點睡的人";
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = @"適合想要早點起床的人";
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"HopeToGoToBedPage"];
            page2.title = @"希望上床時間";
            
            [self.navigationController pushViewController:page2 animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    
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
