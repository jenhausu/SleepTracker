//
//  SessionAnalsis.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/8/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "SessionAnalsis.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"

@implementation SessionAnalsis

- (void)startSession
{
    [self crashlytics];
    [self flurry];
}

- (void)crashlytics
{
    [Fabric with:@[CrashlyticsKit]];
}

- (void)flurry
{
    [Flurry startSession:@"8YZ68WS3RF7MDS5PY43D"];
}

@end
