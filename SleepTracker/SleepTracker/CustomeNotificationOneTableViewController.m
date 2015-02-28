//
//  CustomeNotificationOneTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomeNotificationOneTableViewController.h"

#import "CustomNotification-Model.h"
#import "CustomNotification.h"

@interface CustomeNotificationOneTableViewController ()

@property (strong, nonatomic) NSArray *fetchDataArray;

@property (strong, nonatomic) CustomNotification_Model *customNotificationModel;
@property (strong, nonatomic) CustomNotification *customNotification;

@end

@implementation CustomeNotificationOneTableViewController

@synthesize fetchDataArray;

- (CustomNotification_Model *)customNotificationModel
{
    if (!_customNotificationModel) {
        _customNotificationModel = [[CustomNotification_Model alloc] init];
    }
    
    return _customNotificationModel;
}

- (CustomNotification *)customNotification
{
    if (!_customNotification) {
        _customNotification = [[CustomNotification alloc] init];
    }
    
    return _customNotification;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    fetchDataArray = [self.customNotificationModel fetchAllCustomNotificationData];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return fetchDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";

    self.customNotification = fetchDataArray[indexPath.row];
    cell.textLabel.text = self.customNotification.message;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: self.customNotification.fireDate]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        for (NSInteger row = 0 ; row < fetchDataArray.count ; row++ )
        {
            if (row == indexPath.row)
            {
                self.customNotification = fetchDataArray[indexPath.row];
                
                UIApplication *application = [UIApplication sharedApplication];
                NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
                
                NSDictionary *userInfo;
                NSString *value;
                UILocalNotification *localNotification;
                
                for (NSInteger i = 0 ; i < arrayOfAllLocalNotification.count ; i++ )
                {
                    localNotification = arrayOfAllLocalNotification[i];
                    userInfo = localNotification.userInfo;
                    value = [userInfo objectForKey:@"NotificationType"];
                    
                    if ([value isEqualToString:@"CustomNotification"]) {
                        if ([self.customNotification.fireDate isEqualToDate:localNotification.fireDate]) {
                            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
                        }
                    }
                }
                
                [self.customNotificationModel deleteSpecificCustomNotification:fetchDataArray[indexPath.row]];
                fetchDataArray = [self.customNotificationModel fetchAllCustomNotificationData];

                break;
            }
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
