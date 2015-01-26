//
//  CustomeNotificationOneTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomeNotificationOneTableViewController.h"

@interface CustomeNotificationOneTableViewController ()

@property (strong, nonatomic) NSArray *arrayOfAllLocalNotification;
@property (strong, nonatomic) NSMutableArray *CustomNotification;
@property (strong, nonatomic) UILocalNotification *localNotification;

@end

@implementation CustomeNotificationOneTableViewController

@synthesize arrayOfAllLocalNotification, CustomNotification, localNotification;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CustomNotification = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    UIApplication *application = [UIApplication sharedApplication];
    arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    
    localNotification = arrayOfAllLocalNotification[0];
    NSDictionary *userInfo;
    NSString *value;
    [CustomNotification removeAllObjects];
    
    for (NSInteger i = 0 ; i < arrayOfAllLocalNotification.count ; i++ ) {
        localNotification = arrayOfAllLocalNotification[i];
        userInfo = localNotification.userInfo;
        value = [userInfo objectForKey:@"NotificationType"];
        
        if ([value isEqualToString:@"CustomNotification"]) {
            [CustomNotification addObject:localNotification];
        }
    }

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CustomNotification.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    localNotification = CustomNotification[indexPath.row];
    cell.textLabel.text = localNotification.alertBody;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", localNotification.fireDate];
    
    return cell;
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

- (IBAction)add:(id)sender {
    UINavigationController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"setCustomNotification"];
    [self presentViewController:page2 animated:YES completion:nil];
}

@end
