//
//  SleepData.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SleepData : NSManagedObject

@property (nonatomic, retain) NSDate * goToBedTime;
@property (nonatomic, retain) NSNumber * sleepTime;
@property (nonatomic, retain) NSDate * wakeUpTime;
@property (nonatomic, retain) NSString * sleepType;

@end
