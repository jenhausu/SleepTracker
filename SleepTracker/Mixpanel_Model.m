//
//  Mixpanel_Model.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/8/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "Mixpanel_Model.h"
#import "Mixpanel.h"

@implementation Mixpanel_Model

- (void)trackEvent:(NSString *)event key:(NSString *)key value:(id)value
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:event properties:@{key: value}];
}

- (void)trackEvent:(NSString *)event
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:event properties:nil];
}

@end
