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

#pragma mark - decide Which Data To Proccess

- (void)decideWhichDataToProccess:(NSInteger)row
{
    fetchDataArray = [self fetchSleepDataSortWithAscending:NO];
    self.sleepData = fetchDataArray[row];
}

#pragma mark - add new data

- (void)addNewEmptySleepdata
{
    [NSEntityDescription insertNewObjectForEntityForName:@"SleepData" inManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:nil];
}

- (void)updateAllSleepdataInRow:(NSInteger)row goToBedTime:(NSDate *)goToBedTime wakeUpTime:(NSDate *)wakeUpTime sleepTime:(NSNumber *)sleepTime sleepType:(NSString *)sleepType
{
    [self decideWhichDataToProccess:row];
    
    self.sleepData.goToBedTime = goToBedTime;
    self.sleepData.wakeUpTime = wakeUpTime;
    self.sleepData.sleepTime = sleepTime;
    self.sleepData.sleepType = sleepType;

    [self.managedObjectContext save:nil];
}

- (void)addNewSleepdataAndAddGoToBedTime:(NSDate *)goToBedTime wakeUpTime:(NSDate *)wakeUpTime sleepTime:(NSNumber *)sleepTime sleepType:(NSString *)sleepType
{
    SleepData *newSleepData = [NSEntityDescription insertNewObjectForEntityForName:@"SleepData" inManagedObjectContext:self.managedObjectContext];
    
    newSleepData.goToBedTime = goToBedTime;
    newSleepData.wakeUpTime = wakeUpTime;
    newSleepData.sleepTime = sleepTime;
    newSleepData.sleepType = sleepType;
    
    [self.managedObjectContext save:nil];
}

#pragma mark - fetch data

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

#pragma mark - delete

- (void)deleteSleepData:(NSManagedObject *)dataArray
{
    [self.managedObjectContext deleteObject:dataArray];
    [self.managedObjectContext save:nil];
}

#pragma mark -

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
