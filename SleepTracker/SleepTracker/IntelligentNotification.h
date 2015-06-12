//
//  IntelligentNotification.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntelligentNotification : NSObject

- (NSDate *)decideShouldGoToBedTime;
- (NSArray *)decideFireDate;
- (NSArray *)decideNotificationTitle;
- (void)rescheduleIntelligentNotification;
- (void)deleteAllIntelligentNotification;

@end
