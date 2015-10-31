//
//  Mixpanel_Model.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/8/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mixpanel_Model : NSObject

- (void)trackEvent:(NSString *)event key:(NSString *)key value:(id)value;
- (void)trackEvent:(NSString *)event;

@end
