//
//  LocalNotification.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotification : NSObject

- (void)setLocalNotificationWithMessage:(NSString *)message fireDate:(NSDate *)fireDate repeatOrNot:(BOOL)repeat Sound:(NSString *)sound
                               setValue:(id)value forKey:(NSString *)key;
@end
