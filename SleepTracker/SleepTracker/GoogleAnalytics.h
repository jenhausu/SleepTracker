//
//  GoogleAnalytics.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/6/28.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleAnalytics : NSObject

- (void)trackPageView:(NSString *)screenName;

@end
