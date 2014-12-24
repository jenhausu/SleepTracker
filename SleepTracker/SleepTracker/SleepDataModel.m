//
//  SleepDataModel.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "SleepDataModel.h"
#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SleepData.h"

@interface SleepDataModel ()

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end



@implementation SleepDataModel

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
