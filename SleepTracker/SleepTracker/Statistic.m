//
//  Statistic.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/20.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "Statistic.h"

#import "SleepDataModel.h"
#import "SleepData.h"

@interface Statistic ()

@property (strong, nonatomic) NSNumber *MIN;
@property (strong, nonatomic) NSNumber *MAX;
@property (strong, nonatomic) NSNumber *AVG;

@property (strong, nonatomic) SleepDataModel *sleepDataModel;
@property (strong, nonatomic) NSArray *fetchArray;
@property (nonatomic, strong) SleepData *sleepData;

@end

@implementation Statistic

@synthesize MIN, MAX, AVG, fetchArray;

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc]init];
    }
    return _sleepDataModel;
}

- (void)Initailize {
    MIN = [NSNumber numberWithFloat:99999999];
    MAX = [NSNumber numberWithFloat:0];
    AVG = [NSNumber numberWithFloat:0];
    
    fetchArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    
}

- (NSArray *)showSleepTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];

    
    NSArray *array = @[MIN, MAX, AVG];
    return array;
}

- (NSArray *)showGoToBedTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];

    
    NSArray *array = @[MIN, MAX, AVG];
    return array;
}

- (NSArray *)showWakeUpTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];
    
    
    NSArray *array = @[MIN, MAX, AVG];
    return array;
}

#pragma mark -

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger time = (NSInteger)interval;
    NSInteger minutes = abs((time / 60) % 60);
    NSInteger hours = abs((int)(time / 3600));  //取整數
    
    if (time >= 0)
        return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
    else
        return [NSString stringWithFormat:@"-%02li:%02li", (long)hours, (long)minutes];
}

@end
