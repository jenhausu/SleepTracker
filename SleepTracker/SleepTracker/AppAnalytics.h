//
//  AppAnalytics.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/7/24.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppAnalytics : NSObject

- (void)didFinishLaunchingWithOptions;

@end

#ifdef DEBUG
    #define RELEASE_MODE NO
#else
    #define RELEASE_MODE YES
#endif