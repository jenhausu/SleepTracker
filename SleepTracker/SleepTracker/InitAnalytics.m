//
//  InitAnalytics.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/8/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "InitAnalytics.h"
#import <Google/Analytics.h>
#import "Mixpanel.h"

@implementation InitAnalytics

- (void)initAnalytics
{
    [self initGoogleAnalytics];
    [self initMixpanel];
}

- (void)initGoogleAnalytics
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

- (void)initMixpanel
{
#define MIXPANEL_TOKEN @"0b75510342d69461a74f4c505ab6a8bf"
    
    // Initialize the library with your Mixpanel project token, MIXPANEL_TOKEN
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
}

@end
