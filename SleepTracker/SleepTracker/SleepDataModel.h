//
//  SleepDataModel.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface SleepDataModel : NSObject

- (void)addNewData;

- (void)updateAllSleepDataInRow:(NSInteger)row goToBedTime:(NSDate *)goToBedTime wakeUpTime:(NSDate *)wakeUpTime sleepTiem:(NSNumber *)sleepTime sleepType:(NSString *)sleepType;

- (NSArray *)fetchSleepDataSortWithAscending:(BOOL)ascending;
- (void)deleteSleepData:(NSManagedObject *)dataArray;

@end
