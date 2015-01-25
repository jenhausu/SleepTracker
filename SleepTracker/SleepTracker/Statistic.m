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

@interface Statistic () {
    NSInteger MIN, MAX, AVG;
    NSInteger today, dataDate, lastDataDate, row, Correction;
}

@property (strong, nonatomic) SleepDataModel *sleepDataModel;
@property (strong, nonatomic) NSArray *fetchArray;
@property (nonatomic, strong) SleepData *sleepData;

@end

@implementation Statistic

@synthesize fetchArray;

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc]init];
    }
    return _sleepDataModel;
}

- (void)Initailize
{
    MAX = 0;
    MIN = 99999999;
    AVG = 0;
    
    fetchArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    if (fetchArray.count > 0 ) {
        self.sleepData = fetchArray[0];
    }
}

- (NSArray *)showSleepTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];
    
    if (fetchArray.count >= 2 || (fetchArray.count == 1 && self.sleepData.wakeUpTime > 0) )
    {
        row = ([self.sleepData.sleepTime floatValue] == 0) ? 1 : 0 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
        self.sleepData = fetchArray[row];
        NSInteger sleepTime;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"DDD"];  // 1~366 一年的第幾天
        
        today = [[formatter stringFromDate:[NSDate date]] integerValue];
        dataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue];
        lastDataDate = dataDate + 1 ;
        
        NSInteger lastMinDate = dataDate + 1;
        NSMutableArray *lastMinStack = [[NSMutableArray alloc] init];
        
        NSInteger sleepTimeSum = 0;
        NSInteger sleepTimeSumTem = 0;
        NSInteger lastDataSleepTime = 0;
        
        Correction = (today != dataDate) ? (today - dataDate) : 0 ;
        
        while ( dataDate > (today - recent) ) {
            if ([self.sleepData.sleepType isEqualToString:@"一般"])
            {
                sleepTime = [self.sleepData.sleepTime integerValue];
                sleepTimeSum += sleepTime;
                
                if (dataDate != lastDataDate) {
                    sleepTimeSumTem = 0;  //歸零
                    
                    if (sleepTime > MAX) {
                        MAX = sleepTime;
                    }
                    
                    if (sleepTime < MIN) {
                        MIN = sleepTime;
                        
                        lastMinDate = dataDate;
                        [lastMinStack addObject:[NSNumber numberWithFloat:sleepTime]];  //加入堆疊中
                    }
                } else if (dataDate == lastDataDate) {  //兩筆資料是同一天
                    sleepTimeSumTem += sleepTime + lastDataSleepTime;
                    
                    if (sleepTimeSumTem > MAX) {  //處理最大值
                        MAX = sleepTimeSumTem;
                    }
                    
                    if (lastMinDate == dataDate) {  //處理最小值
                        if (lastMinStack.count >= 2) {   //堆疊數量超過一個
                            if (sleepTimeSumTem < [lastMinStack[lastMinStack.count -2] integerValue]) {
                                MIN = sleepTimeSumTem;
                                lastMinDate = dataDate;
                                
                                [lastMinStack removeLastObject];
                                [lastMinStack addObject:[NSNumber numberWithInteger:sleepTimeSumTem]];
                            } else {
                                MIN = [lastMinStack[lastMinStack.count - 2] integerValue];
                                lastMinDate = dataDate;
                                
                                [lastMinStack removeLastObject];
                            }
                        } else {
                            MIN = sleepTimeSumTem;
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
        AVG = sleepTimeSum / (today - lastDataDate + 1 - Correction);
    } else {
        MIN = 0;
        MAX = 0;
        AVG = 0;
    }
    
    if (MIN == 99999999) {
        MIN = 0;
    }
    
    return @[[NSNumber numberWithFloat:MIN], [NSNumber numberWithFloat:MAX], [NSNumber numberWithFloat:AVG]];
}

- (NSArray *)showGoToBedTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];
    
    return @[[NSNumber numberWithFloat:MIN], [NSNumber numberWithFloat:MAX], [NSNumber numberWithFloat:AVG]];
}

- (NSArray *)showWakeUpTimeDataInTheRecent:(NSInteger)recent
{
    [self Initailize];
    if (fetchArray.count >= 2 || (fetchArray.count == 1 && self.sleepData.wakeUpTime > 0) )
    {
        
    } else {
        MIN = 0;
        MAX = 0;
        AVG = 0;
    }
    
    if (MIN == 99999999) {
        MIN = 0;
    }

    return @[[NSNumber numberWithInteger:MIN], [NSNumber numberWithInteger:MAX], [NSNumber numberWithInteger:AVG]];
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
