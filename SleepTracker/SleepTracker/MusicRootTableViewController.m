//
//  MusicRootTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/7/13.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "MusicRootTableViewController.h"

@interface MusicRootTableViewController ()

@property (nonatomic) NSArray *musicRoot;
@property (nonatomic) NSArray *switcher;
@property (nonatomic) NSArray *musicResource;
@property (nonatomic) NSArray *time;

@property (nonatomic) NSUserDefaults *userPreferences;
@property (assign, nonatomic) NSUInteger selectedRow;

@end

@implementation MusicRootTableViewController

@synthesize musicRoot, switcher, musicResource, time;
@synthesize userPreferences, selectedRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userPreferences =  [NSUserDefaults standardUserDefaults];
    
    switcher = @[@"睡前播放音樂"];
    musicResource = @[@"音樂選擇"];
    time = @[@"十分鐘", @"十五分鐘", @"二十分鐘"];
    musicRoot = ([userPreferences boolForKey:@"睡前播放音樂"]) ? @[switcher, musicResource, time] : @[switcher] ;
    
    selectedRow = [userPreferences integerForKey:@"音樂播放時間"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return musicRoot.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [musicRoot[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = musicRoot[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 30.0)];
            cell.accessoryView = switchControl;
            switchControl.on = [userPreferences boolForKey:@"睡前播放音樂"];
            [switchControl addTarget:self action:@selector(switchChanged1:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.detailTextLabel.text = @" ";
        }
    } else if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 2) {
        cell.detailTextLabel.text = @" ";
        
        if (indexPath.row == selectedRow) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    return cell;
}

#pragma mark - Header

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"音樂播放時間";
    }
    return nil;
}

#pragma mark - didSelect

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        /*
        UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"page2"];
        page2.title = @"";
        
        [self.navigationController pushViewController:page2 animated:YES];  //*/
    } else if (indexPath.section == 2) {
        // 原本選擇的 row
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:indexPath.section];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        // 新選擇的 row
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // 設定新的選擇
        selectedRow = indexPath.row;
        [userPreferences setInteger:selectedRow forKey:@"音樂播放時間"];
    }
}

#pragma mark - switchChinaged

- (void)switchChanged1:(id)sender
{
    UISwitch *switchControl = sender;
    [userPreferences setBool:switchControl.on forKey:@"睡前播放音樂"];
    
    
    [self.tableView beginUpdates];
    if ([userPreferences boolForKey:@"睡前播放音樂"]) {
        musicRoot = @[switcher, musicResource, time];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        musicRoot = @[switcher];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];  //*/
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
