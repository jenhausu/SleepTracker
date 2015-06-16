//
//  SleepNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/6/14.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SleepNotification.h"

#import "IntelligentNotification.h"
#import "CustomNotification-Model.h"

@implementation SleepNotification

- (void)resetSleepNotification
{
    [[[IntelligentNotification alloc] init] rescheduleIntelligentNotification];
    [[[CustomNotification_Model alloc] init] resetCustomNotification];
}

@end
