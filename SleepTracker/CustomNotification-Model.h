//
//  CustomNotification-Model.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/27.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"

@interface CustomNotification_Model : NSObject

- (void)addNewCustomNotification:(NSString *)message fireDate:(NSDate *)fireDate sound:(NSString *)sound;
- (void)cancelSpecificCustomNotification:(NSManagedObject *)dataArray row:(NSInteger)row;
- (void)cancelAllCustomNotification;
- (NSArray *)fetchAllCustomNotificationData;
- (void)setCustomNotificatioin;
- (void)resetCustomNotification;
- (void)updateRow:(NSInteger)row message:(NSString *)message fireDate:(NSDate *)fireDate on:(BOOL)on;

@end
