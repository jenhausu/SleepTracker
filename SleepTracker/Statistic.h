//
//  Statistic.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Statistic : NSObject

- (NSArray *)sleepTimeStatisticalDataInTheRecent:(NSInteger)recent;
- (NSArray *)goToBedTimeStatisticalDataInTheRecent:(NSInteger)recent;
- (NSArray *)wakeUpTimeStatisticalDataInTheRecent:(NSInteger)recent;

- (NSString *)calculateGetUpTooLatePercentage:(NSInteger)recent;
- (NSString *)calculateGoToBedTooLatePercentage:(NSInteger)recent;

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;

@end
