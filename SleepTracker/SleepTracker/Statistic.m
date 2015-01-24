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
    
    NSInteger Max = 0;
    NSInteger Min = 99999999;
    NSInteger Avg = 0;
    
    if (fetchArray.count > 0 ) {
        self.sleepData = fetchArray[0];
        if (fetchArray.count >= 2 || (fetchArray.count == 1 && self.sleepData.wakeUpTime > 0) )
        {
            self.sleepData = fetchArray[([self.sleepData.sleepTime floatValue] == 0) ? 1 : 0 ];  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"DDD"];  // 1~366 一年的第幾天
            NSInteger today = [[formatter stringFromDate:[NSDate date]] integerValue];
            NSInteger dataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue];
            NSInteger lastDataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue] + 1 ;

            while ( dataDate > (today - recent) ) {
                if ([self.sleepData.sleepType isEqualToString:@"一般"]) {
                    if (dataDate != lastDataDate) {
                        
                    } else if (dataDate == lastDataDate) {
                        
                    }
                }
            }
        }
    } else {
        Min = 0;
        Max = 0;
        Avg = 0;
    }
    if (Min == 99999999) {
        Min = 0;
    }
    
    return @[[NSNumber numberWithFloat:Min], [NSNumber numberWithFloat:Max], [NSNumber numberWithFloat:Avg]];
}

- (NSArray *)showGoToBedTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];

    
    return @[MIN, MAX, AVG];
}

- (NSArray *)showWakeUpTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];
    
    
    return @[MIN, MAX, AVG];
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
