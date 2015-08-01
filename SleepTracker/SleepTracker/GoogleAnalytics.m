//
//  GoogleAnalytics.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/6/28.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "GoogleAnalytics.h"
#import <Google/Analytics.h>

@interface GoogleAnalytics ()

@property (nonatomic) id<GAITracker> tracker;

@end


@implementation GoogleAnalytics

@synthesize tracker;

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

- (void)initTracker
{
    tracker = [[GAI sharedInstance] defaultTracker];
}

- (void)trackPageView:(NSString *)screenName
{
    [self initTracker];
    
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    [self initTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
    
}

@end
