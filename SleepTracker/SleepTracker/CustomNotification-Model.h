//
//  CustomNotification-Model.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/27.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomNotification_Model : NSObject

- (void)addNewCustomNotification:(NSString *)message fireDate:(NSDate *)fireDate repeat:(BOOL)repeat sound:(NSString *)sound;
- (void)deleteSpecificCustomNotification:(NSDate *)fireDate;
- (void)deleteAllCustomNotification;
- (NSArray *)fetchAllCustomNotificationData;
- (void)setCustomNotificatioin;

@end
