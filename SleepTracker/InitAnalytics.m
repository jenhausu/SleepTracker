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
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"

@implementation InitAnalytics

- (void)initAnalytics
{
    [self initGoogleAnalytics];
    [self initMixpanel];
    [self crashlytics];
    [self flurry];
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
#define MIXPANEL_TEST_TOKEN @"d15c0cbaa13095c4b50b621c262ab09e"
    
    // Initialize the library with your Mixpanel project token, MIXPANEL_TOKEN
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
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
