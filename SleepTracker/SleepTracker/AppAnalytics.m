//
//  AppAnalytics.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/7/24.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "AppAnalytics.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Google/Analytics.h>

@implementation AppAnalytics

- (void)appAnalytics {
    [self crashlytics];
    [self googleAnalytics];
}

- (void)crashlytics
{
    [Fabric with:@[CrashlyticsKit]];  //避免在開發的時候一直觸動 Crashlytics，污染我的數據
}

- (void)googleAnalytics
{
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
}

@end
