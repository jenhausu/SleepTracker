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
            NSInteger row = ([self.sleepData.sleepTime floatValue] == 0) ? 1 : 0 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
            self.sleepData = fetchArray[row];  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
            NSInteger sleepTime;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"DDD"];  // 1~366 一年的第幾天
            
            NSInteger today = [[formatter stringFromDate:[NSDate date]] integerValue];
            NSInteger dataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue];
            NSInteger lastDataDate = dataDate + 1 ;

            NSInteger lastMinDate = dataDate + 1;
            NSMutableArray *lastMinStack = [[NSMutableArray alloc] init];

            NSInteger sleepTimeSum = 0;
            NSInteger sleepTimeSumTem = 0;
            NSInteger lastDataSleepTime = 0;
            
            NSInteger Correction = (today != dataDate) ? (today - dataDate) : 0 ;
            
            while ( dataDate > (today - recent) ) {
                if ([self.sleepData.sleepType isEqualToString:@"一般"])
                {
                    sleepTime = [self.sleepData.sleepTime integerValue];
                    sleepTimeSum += sleepTime;
                    
                    if (dataDate != lastDataDate) {
                        sleepTimeSumTem = 0;  //歸零
                        
                        if (sleepTime > Max) {
                            Max = sleepTime;
                        }
                        
                        if (sleepTime < Min) {
                            Min = sleepTime;
                            
                            lastMinDate = dataDate;
                            [lastMinStack addObject:[NSNumber numberWithFloat:sleepTime]];  //加入堆疊中
                        }
                    } else if (dataDate == lastDataDate) {  //兩筆資料是同一天
                        sleepTimeSumTem += sleepTime + lastDataSleepTime;
                        
                        if (sleepTimeSumTem > Max) {  //處理最大值
                            Max = sleepTimeSumTem;
                        }
                        
                        if (lastMinDate == dataDate) {  //處理最小值
                            if (lastMinStack.count >= 2) {   //堆疊數量超過一個
                                if (sleepTimeSumTem < [lastMinStack[lastMinStack.count -2] integerValue]) {
                                    Min = sleepTimeSumTem;
                                    lastMinDate = dataDate;
                                    
                                    [lastMinStack removeLastObject];
                                    [lastMinStack addObject:[NSNumber numberWithInteger:sleepTimeSumTem]];
                                } else {
                                    Min = [lastMinStack[lastMinStack.count - 2] integerValue];
                                    lastMinDate = dataDate;
                                    
                                    [lastMinStack removeLastObject];
                                }
                            } else {
                                Min = sleepTimeSumTem;
                                lastMinDate = dataDate;
                                
                                [lastMinStack removeLastObject];
                                [lastMinStack addObject:[NSNumber numberWithInteger:sleepTimeSumTem]];
                            }
                        }
                    }
                    
                    lastDataSleepTime = sleepTime;
                    lastDataDate = dataDate;
                    
                    if (lastDataDate - dataDate > 1) {  //如果中間有一天是沒有輸入資料的話進行校正，中間這幾天不納入計算
                        Correction += (lastDataDate - dataDate) - 1;
                    }
                }
                if (++row < fetchArray.count) {
                    self.sleepData = fetchArray[row];
                    dataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue];
                } else {
                    break;  //如果總資料比數少於所需要計算的天數，直接跳出
                }
            }
            Avg = sleepTimeSum / (today - lastDataDate + 1 - Correction);
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
