//
//  SettingTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/12.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SettingTableViewController.h"

#import <MessageUI/MessageUI.h>

#import "IntelligentNotification.h"

@interface SettingTableViewController ()  <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *textLabelOfTableViewCell;

@end

@implementation SettingTableViewController

@synthesize section1, section2, textLabelOfTableViewCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"希望上床時間"];
    section2 = @[@"意見回饋"];
    textLabelOfTableViewCell = @[section1, section2];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return textLabelOfTableViewCell.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [textLabelOfTableViewCell[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = textLabelOfTableViewCell[indexPath.section][indexPath.row];
    cell.detailTextLabel.text = @" ";
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:mm"];
            
            cell.detailTextLabel.text = [formatter stringFromDate:[[[IntelligentNotification alloc] init] decideShouldGoToBedTime]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *page2;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ShouldGoToSleepTime"];
        }
        
        page2.title = section1[indexPath.row];
        [self.navigationController pushViewController:page2 animated:YES];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                
                [mailViewController setToRecipients:[NSArray arrayWithObject:@"jenhausu@icloud.com"]];
                
                [self presentViewController:mailViewController animated:YES completion:NULL];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
