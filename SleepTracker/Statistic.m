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

#define MIN_Default 99999999
#define MAX_Default -9999999
#define AVG_Default -9999999

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc]init];
    }
    return _sleepDataModel;
}

- (void)Initailize
{
    MAX = MAX_Default;
    MIN = MIN_Default;
    AVG = AVG_Default;
    
    fetchArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    if (fetchArray.count > 0 ) {
        self.sleepData = fetchArray[0];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    dataDate = [[formatter stringFromDate:self.sleepData.wakeUpTime] integerValue];
    lastDataDate = dataDate + 1;
}

#pragma mark - Calculate MAX, MIN, AVG

- (NSArray *)sleepTimeStatisticalDataInTheRecent:(NSInteger)recent;
{
    [self Initailize];
    
    if (fetchArray.count >= 2 || (fetchArray.count == 1 && self.sleepData.wakeUpTime > 0) )
    {
        row = self.sleepData.wakeUpTime ? 0 : 1 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
        self.sleepData = fetchArray[row];
        NSInteger sleepTime;
        
        today = [self dateOrdinal:[NSDate date]];
        dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
        lastDataDate = dataDate + 1 ;
        
        NSInteger minDate = dataDate + 1;
        NSMutableArray *minDateStack = [[NSMutableArray alloc] init];  //儲存所有曾經是最小睡眠時間的那筆資料的日期（一天中的第幾天）
        NSMutableArray *minStack = [[NSMutableArray alloc] init];  //儲存所有曾經是最小值的睡眠時間
        
        NSInteger sleepTimeSum = 0;
        NSInteger todaySleepTimeSum = 0;
        NSInteger lastDataSleepTime = 0;
        
        Correction = (today != dataDate) ? (today - dataDate) : 0 ;
        
        while ( dataDate > (today - recent) ) {
            sleepTime = [self.sleepData.sleepTime integerValue];
            sleepTimeSum += sleepTime;
            
            if (dataDate != lastDataDate) {
                todaySleepTimeSum = 0;  //歸零
                lastDataSleepTime = sleepTime;
                
                if (sleepTime > MAX) {
                    MAX = sleepTime;
                }
                if (sleepTime < MIN) {
                    MIN = sleepTime;
                    [minStack addObject:[NSNumber numberWithFloat:sleepTime]];
                    
                    minDate = dataDate;
                    [minDateStack addObject:[NSNumber numberWithInteger:minDate]];
                }
            } else if (dataDate == lastDataDate) {  //兩筆資料是同一天
                todaySleepTimeSum = sleepTime + lastDataSleepTime;  //今天的資料加上上一筆資料（因為兩筆資料同一天），翻成人話就是sleepTimeSumTem儲存了同一天睡覺時間的總和
                lastDataSleepTime = todaySleepTimeSum;
                
                if (todaySleepTimeSum > MAX) {  //處理最大值
                    MAX = todaySleepTimeSum;
                }
                
                if (minDate == dataDate) {  //處理最小值
                    if (minStack.count >= 2) {   //堆疊數量超過一個
                        if (todaySleepTimeSum < [minStack[minStack.count - 2] integerValue]) {
                            MIN = todaySleepTimeSum;
                            [minStack removeLastObject];
                            [minStack addObject:[NSNumber numberWithInteger:todaySleepTimeSum]];
                            
                            minDate = dataDate;
                            [minDateStack removeLastObject];
                            [minDateStack addObject:[NSNumber numberWithInteger:minDate]];
                        } else {
                            if (dataDate == [minDateStack[minDateStack.count - 1] integerValue]) {
                                MIN = [minStack[minStack.count - 2] integerValue];
                                [minStack removeLastObject];
                                
                                minDate = [minDateStack[minDateStack.count - 2] integerValue];
                                [minDateStack removeLastObject];
                            }
                        }
                    } else {
                        MIN = todaySleepTimeSum;
                        [minStack removeLastObject];
                        [minStack addObject:[NSNumber numberWithInteger:todaySleepTimeSum]];
                        
                        minDate = dataDate;
                        [minDateStack removeLastObject];
                        [minDateStack addObject:[NSNumber numberWithInteger:minDate]];
                    }
                }
            }
            
            // 校正，如果中間有一天是沒有輸入資料的話進行校正，中間這幾天不納入計算
            if (lastDataDate - dataDate > 1) {
                Correction += (lastDataDate - dataDate) - 1;
            }
            
            lastDataDate = dataDate;
            
            
            if (++row < fetchArray.count) {
                self.sleepData = fetchArray[row];
                dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            } else {
                break;  //如果總資料比數少於所需要計算的天數，直接跳出
            }
        }
        
        if (today - lastDataDate + 1 - Correction) {
            AVG = sleepTimeSum / (today - lastDataDate + 1 - Correction);
        }
    }
    
    if (MIN == MIN_Default) {
        MIN = 0;
    }
    
    if (MAX == MAX_Default) {
        MAX = 0;
    }
    
    
    return @[[NSNumber numberWithFloat:MIN], [NSNumber numberWithFloat:MAX], [NSNumber numberWithFloat:AVG]];
}

- (NSArray *)goToBedTimeStatisticalDataInTheRecent:(NSInteger)recent;
{
    MAX = MAX_Default;
    MIN = MIN_Default;
    AVG = AVG_Default;
    
    fetchArray = [self.sleepDataModel fetchSleepDataSortWithAscending:YES];
    if (fetchArray.count > 0 ) {
        self.sleepData = fetchArray[0];
        
        if (([fetchArray count] == 1 && ([self.sleepData.sleepTime floatValue] > 0)) || [fetchArray count] >= 2)  //起碼要有一筆完整的資料
        {
            row = self.sleepData.wakeUpTime ? 0 : 1 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
            self.sleepData = fetchArray[row];
            
            today = [self dateOrdinal:[NSDate date]];
            dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            lastDataDate = dataDate + 1;
            
            NSInteger goToBedTimeInSecond, avgCount = 0;
            AVG = -86399;
            
            NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents;
            
            for (int i = 0 ; i < fetchArray.count ; i++ ) {
                self.sleepData = fetchArray[i];
                dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
                
                if ( dataDate > (today - recent) ) {
                    if ([self.sleepData.sleepType isEqualToString:@"一般"]) {
                        if (dataDate != lastDataDate) {
                            dateComponents = [greCalendar components: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self.sleepData.goToBedTime];
                            
                            // 計算數據
                            goToBedTimeInSecond = (dataDate == [self dateOrdinal:self.sleepData.goToBedTime]) ?
                            dateComponents.second + dateComponents.minute*60 + dateComponents.hour*3600 :
                            (dateComponents.second + dateComponents.minute*60 + dateComponents.hour*3600) - 86400;
                            
                            // 判斷有無最小值
                            if ( goToBedTimeInSecond < MIN) MIN = goToBedTimeInSecond;
                            
                            // 判斷有無最大值
                            if (goToBedTimeInSecond > MAX) MAX = goToBedTimeInSecond;
                            
                            // 計算平均值
                            avgCount++;
                            if (AVG == AVG_Default) {
                                AVG = goToBedTimeInSecond;
                            } else {
                                AVG = (AVG * (avgCount - 1) + goToBedTimeInSecond) / avgCount;
                            }
                            
                            // 儲存現在這筆資料的天數為lastDataDate
                            lastDataDate = dataDate;
                        }
                    }
                }
            }
        }
    }
    
    if (MIN == MIN_Default) {
        MIN = 0;
    } else if (MIN < 0) {
        MIN += 86400;
    }
    
    if (MAX == MAX_Default) {
        MAX = 0;
    } else if (MAX < 0) {
        MAX += 86400;
    }
    
    
    return @[[NSNumber numberWithFloat:MIN], [NSNumber numberWithFloat:MAX], [NSNumber numberWithFloat:AVG]];
}

- (NSArray *)wakeUpTimeStatisticalDataInTheRecent:(NSInteger)recent;
{
    [self Initailize];
    if (fetchArray.count >= 2 || (fetchArray.count == 1 && self.sleepData.wakeUpTime > 0) )
    {
        row = self.sleepData.wakeUpTime ? 0 : 1 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
        self.sleepData = fetchArray[row];
        
        today = [self dateOrdinal:[NSDate date]];
        dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
        lastDataDate = dataDate + 1;
        
        NSDate *wakeUpTime;
        NSInteger wakeUpTimeInSecond;
        
        NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents;
        
        while ( dataDate > (today - recent) )   //dataDate > (today - recent) 看天數
        {
            if ([self.sleepData.sleepType isEqualToString:@"一般"]) {
                wakeUpTime = self.sleepData.wakeUpTime;
                
                dateComponents = [greCalendar components: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond  fromDate:wakeUpTime];
                wakeUpTimeInSecond = dateComponents.second + dateComponents.minute*60 + dateComponents.hour*3600 ;
                
                if (lastDataDate != dataDate) {
                    if ( wakeUpTimeInSecond < MIN) MIN = wakeUpTimeInSecond;
                    if ( wakeUpTimeInSecond > MAX ) MAX = wakeUpTimeInSecond;
                }
                
                lastDataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            }
            
            if (++row < [fetchArray count]) {
                self.sleepData = fetchArray[row];
                dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            } else {
                break;  //如果總資料比數少於所需要計算的天數，直接跳出
            }
        }
        
        
        
        /* 計算平均值 */
        self.sleepData = fetchArray[0];
        row = (self.sleepData.wakeUpTime) ? 0 : 1 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
        self.sleepData = fetchArray[row];
        
        dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
        lastDataDate = dataDate + 1;

        float sumTem = 0;
        
        Correction = (today != dataDate) ? (today - dataDate) : 0 ;

        while ( dataDate > (today - recent) )
        {
            if ([self.sleepData.sleepType isEqualToString:@"一般"] && lastDataDate != dataDate)
            {
                wakeUpTime = self.sleepData.wakeUpTime;
                dateComponents = [greCalendar components: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond  fromDate:wakeUpTime];

                sumTem = sumTem + ((dateComponents.hour * 3600 + dateComponents.minute * 60 + dateComponents.second) - MIN);
                
                // 如果中間有一天是沒有輸入資料的話進行校正，中間這幾天不納入計算
                if (lastDataDate - dataDate > 1)  Correction += (lastDataDate - dataDate) - 1 ;
                lastDataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            }
            
            if (++row == [fetchArray count])  //為了避免資料數比所需要的天數還要少
                break;
            else {
                self.sleepData = fetchArray[row];
                dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            }
        }
        
        
        if ((today - lastDataDate + 1) - Correction) {
            sumTem /= (today - lastDataDate + 1) - Correction;
            AVG = sumTem + MIN;
        }
    }
    
    
    if (MIN == MIN_Default) {
        MIN = 0;
    }
    
    if (MAX == MAX_Default) {
        MAX = 0;
    }
    

    return @[[NSNumber numberWithInteger:MIN], [NSNumber numberWithInteger:MAX], [NSNumber numberWithInteger:AVG]];
}

#pragma mark - Calculate Ratio

- (NSString *)calculateGoToBedTooLatePercentage:(NSInteger)recent
{
    int sleepLate = 0;
    int sleepEarly = 0;
    
    fetchArray = [self.sleepDataModel fetchSleepDataSortWithAscending:YES];
    
    if (fetchArray.count > 0 ) 
    {
        self.sleepData = fetchArray[0];

        today = [self dateOrdinal:[NSDate date]];
        dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
        lastDataDate = dataDate - 1;
        
        NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *goToBedTimeDateComponents, *wakeUpTimeDateComponents;
        
        for (NSInteger i = 0 ; i < fetchArray.count ; i++) {
            self.sleepData = fetchArray[i];

            if ([self.sleepData.sleepType isEqualToString:@"一般"]) {
                dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
                
                if (dataDate != lastDataDate) {
                    if (dataDate > (today - recent)) {
                        goToBedTimeDateComponents = [greCalendar components: NSCalendarUnitDay fromDate:self.sleepData.goToBedTime];
                        wakeUpTimeDateComponents = [greCalendar components: NSCalendarUnitDay fromDate:self.sleepData.wakeUpTime];
                        
                        if (goToBedTimeDateComponents.day == wakeUpTimeDateComponents.day) {
                            sleepLate++;
                        } else {
                            sleepEarly++;
                        }
                    }
                }
                
                lastDataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            }
        }
    }
    return [NSString stringWithFormat:@"%d/%d (%.1f%%)", sleepEarly, (sleepLate + sleepEarly), (float)sleepEarly / (sleepEarly + sleepLate) * 100];
}

- (NSString *)calculateGetUpTooLatePercentage:(NSInteger)recent
{
    [self Initailize];
    int sleepLate = 0;
    int sleepEarly = 0;
    
    if (fetchArray.count >= 2 || (fetchArray.count == 1 && self.sleepData.wakeUpTime > 0) )
    {
        row = ([self.sleepData.sleepTime floatValue] == 0) ? 1 : 0 ;  //如果現在是睡覺狀態，那就跳過第一筆資料，因為第一筆資料還沒有sleepTime的資料
        self.sleepData = fetchArray[row];
        
        today = [self dateOrdinal:[NSDate date]];
        dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
        lastDataDate = dataDate + 1;
        
        NSDate *wakeUpTime;
        
        NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents;
        
        while ( dataDate > (today - recent) )   //dataDate > (today - recent) 看天數
        {
            if ([self.sleepData.sleepType isEqualToString:@"一般"])
            {
                wakeUpTime = self.sleepData.wakeUpTime;
                dateComponents = [greCalendar components: NSCalendarUnitHour fromDate:wakeUpTime];
                
                if (lastDataDate != dataDate) {
                    if (dateComponents.hour >= 9) {
                        sleepLate++;
                    } else {
                        sleepEarly++;
                    }
                }
                
                lastDataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            }
            
            if (++row < [fetchArray count]) {
                self.sleepData = fetchArray[row];
                dataDate = [self dateOrdinal:self.sleepData.wakeUpTime];
            } else {
                break;  //如果總資料比數少於所需要計算的天數，直接跳出
            }
        }
    }
    
    return [NSString stringWithFormat:@"%d/%d (%.1f%%)", sleepEarly, (sleepLate + sleepEarly), (float)sleepEarly / (sleepEarly + sleepLate) * 100];
}

#pragma mark - Internal Method

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger time = (NSInteger)interval;
    NSInteger minutes = labs((time / 60) % 60);
    NSInteger hours = abs((int)(time / 3600));  //取整數
    
    if (time >= 0)
        return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
    else
        return [NSString stringWithFormat:@"-%02li:%02li", (long)hours, (long)minutes];
}

- (NSInteger)dateOrdinal:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyDDD"];  // 天數
    
    return [[formatter stringFromDate:date] integerValue];
}

@end
