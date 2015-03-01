//
//  CustomNotification-Model.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/27.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomNotification-Model.h"

#import "LocalNotification.h"
#import "CustomNotification.h"

@interface CustomNotification_Model ()

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) LocalNotification *localNotification;
@property (strong, nonatomic) CustomNotification *customNotification;

@end

@implementation CustomNotification_Model

#pragma mark - Lazy Intialization

- (LocalNotification *)localNotification
{
    if (!_localNotification) {
        _localNotification = [[LocalNotification alloc] init];
    }
    
    return _localNotification;
}

#pragma mark - Add

- (void)addNewCustomNotification:(NSString *)message fireDate:(NSDate *)fireDate sound:(NSString *)sound
{
    CustomNotification *newCustomNotification = [NSEntityDescription insertNewObjectForEntityForName:@"CustomNotification"
                                                                              inManagedObjectContext:self.managedObjectContext];
    newCustomNotification.message = message;
    newCustomNotification.fireDate = fireDate;
    newCustomNotification.on = [NSNumber numberWithBool:YES];
    newCustomNotification.sound = sound;
    [self.managedObjectContext save:nil];
    
    [self setCustomNotificatioin];
}

#pragma mark - Set

- (void)setCustomNotificatioin
{
    NSArray *fetchDataArray = [self fetchAllCustomNotificationData];
    
    for (NSInteger i = 0 ; i < fetchDataArray.count ; i++ ) {
        self.customNotification = fetchDataArray[i];
        if ([self.customNotification.on boolValue]) {
            [self.localNotification setLocalNotificationWithMessage:self.customNotification.message
                                                           fireDate:self.customNotification.fireDate
                                                        repeatOrNot:YES
                                                              Sound:self.customNotification.sound
                                                           setValue:@"CustomNotification" forKey:@"NotificationType"];
        }
    }
}

- (void)resetCustomNotification
{
    [self cancelAllCustomNotification];
    [self setCustomNotificatioin];
}

#pragma mark - Fetch Data

- (NSArray *)fetchAllCustomNotificationData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CustomNotification" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortByDate, nil];
    fetchRequest.sortDescriptors = sortArray;
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

#pragma mark - Delete

- (void)deleteSpecificCustomNotification:(NSManagedObject *)dataArray row:(NSInteger)row
{
    [self.managedObjectContext deleteObject:dataArray];
    [self.managedObjectContext save:nil];
}

#pragma mark - Cancel

- (void)cancelAllCustomNotification
{
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
            [application cancelLocalNotification:localNotification];
        }
    }
}

#pragma mark - Update

- (void)updateRow:(NSInteger)row message:(NSString *)message fireDate:(NSDate *)fireDate on:(BOOL)on
{
    NSArray *fetchDataArray = [self fetchAllCustomNotificationData];
    
    self.customNotification = fetchDataArray[row];
    self.customNotification.message = message;
    self.customNotification.fireDate = fireDate;
    self.customNotification.on = [NSNumber numberWithBool:on];
    
    [self.managedObjectContext save:nil];
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
