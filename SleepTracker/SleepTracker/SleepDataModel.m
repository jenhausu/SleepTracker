//
//  SleepDataModel.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "SleepDataModel.h"
#import <UIKit/UIKit.h>

#import "SleepData.h"

@interface SleepDataModel ()

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) SleepData *sleepData;
@property (nonatomic, strong) NSArray *fetchDataArray;

@end

@implementation SleepDataModel

@synthesize fetchDataArray;

- (void)decideWhichDataToProccess
{
    fetchDataArray = [self fetchSleepDataSortWithAscending:NO];
    self.sleepData = fetchDataArray[0];
}

- (void)addNewGoToBedTime:(NSDate *)goToBedTime
{
    SleepData *newSleepData = [NSEntityDescription insertNewObjectForEntityForName:@"SleepData" inManagedObjectContext:self.managedObjectContext];
    newSleepData.goToBedTime = goToBedTime;
    [self.managedObjectContext save:nil];
}

- (void)updateAllSleepDataInRow:(NSInteger)row goToBedTime:(NSDate *)goToBedTime wakeUpTime:(NSDate *)wakeUpTime sleepTiem:(NSNumber *)sleepTime sleepType:(NSString *)sleepType
{
    [self decideWhichDataToProccess:row];
    
    self.sleepData.goToBedTime = goToBedTime;
    self.sleepData.wakeUpTime = wakeUpTime;
    self.sleepData.sleepTime = sleepTime;
    self.sleepData.sleepType = sleepType;

    [self.managedObjectContext save:nil];
}

- (NSArray *)fetchSleepDataSortWithAscending:(BOOL)ascending
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepData" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"goToBedTime" ascending:ascending];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortByDate, nil];
    fetchRequest.sortDescriptors = sortArray;
    
    fetchDataArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchDataArray;
}

- (void)deleteSleepData:(NSManagedObject *)dataArray
{
    [self.managedObjectContext deleteObject:dataArray];
    [self.managedObjectContext save:nil];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
