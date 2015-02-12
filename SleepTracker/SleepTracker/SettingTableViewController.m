//
//  SettingTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/12.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SettingTableViewController.h"

#import <MessageUI/MessageUI.h>

@interface SettingTableViewController ()  <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *textLabelOfTableViewCell;

@end

@implementation SettingTableViewController

@synthesize section1, section2, textLabelOfTableViewCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    section1 = @[@"希望上床時間", @"睡前通知"];
    section2 = @[@"意見回饋"];
    textLabelOfTableViewCell = @[section1, section2];
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
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *page2;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"HopeToGoToBedPage"];
        } else if (indexPath.row == 1) {
            page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"SleepNotificationPage"];
        }
        
        [self.navigationController pushViewController:page2 animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0)
        {
            if ([MFMailComposeViewController canSendMail])
            {
                NSString *emailTitle = @"Title";
                NSString *messageBody = @"Message Body";
                NSArray *toRecipents = [NSArray arrayWithObject:@"jenhausu@icloud.com"];
                
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                [mailViewController setSubject:emailTitle];
                [mailViewController setMessageBody:messageBody isHTML:YES];
                [mailViewController setToRecipients:toRecipents];
                
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

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sented");
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
