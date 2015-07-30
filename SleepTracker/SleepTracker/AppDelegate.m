//
//  AppDelegate.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/25.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "AppDelegate.h"
#import "AppAnalytics.h"

#import "LocalNotification.h"

@interface AppDelegate ()  <UIAlertViewDelegate>

@property (nonatomic) UILocalNotification *localNotification;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self firstLaunch];
    [self analytics];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //不管是點擊通知或是直接打開 App，App 開啟就會把所有在通知中心的通知給刪除，這樣就避免使用者要消除通知一定要點擊通知的問題。
    [self removeNotificationFromNotificationCenter];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark -

- (void)firstLaunch
{
    [[[LocalNotification alloc] init] initLocalNotification];
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    if (![userPreferences boolForKey:@"NotFirstLaunch"]) {
        [userPreferences setBool:YES forKey:@"重複發出睡前通知"];
        [userPreferences setBool:YES forKey:@"NotFirstLaunch"];
        
        [userPreferences setBool:YES forKey:@"1.2.0"];
    } else if (![userPreferences boolForKey:@"1.2.0"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"1.2.0版 新功能"
                                                        message:@"1. 現在只要把通知往左滑就會有「稍後通知」、「我要熬夜」的選項了。\n2. 使用者可以決定要不要計算醒來時間。"
                                                       delegate:self
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil, nil];
        
         /*// 設定圖片的方式不夠完美，所以程式碼先留著
         UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
         UIImage *image = [UIImage imageNamed:@"swip5"];
         imageView.contentMode = UIViewContentModeScaleToFill;
         
         
         CGSize newSize = CGSizeMake(image.size.width, image.size.height);
         UIGraphicsBeginImageContext(newSize);
         [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
         image = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
        
        
         imageView.image = image;
         
         //check if os version is 7 or above
         if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
         [alert setValue:imageView forKey:@"accessoryView"];
         }else{
         [alert addSubview:imageView];
         }  //*/
        
        [alert show];
        [userPreferences setBool:YES forKey:@"1.2.0"];
    }
}

- (void)analytics
{
    if (RELEASE_MODE) {
        [[[AppAnalytics alloc] init] didFinishLaunchingWithOptions];
    }
}

#pragma mark - SleepNotification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        _localNotification = notification;
        [self showSleepNotificationAlertView];
    }
    
    [self removeNotificationFromNotificationCenter];  //如果通知發出時剛好使用者在使用App，也把通知從通知中心中移除。
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"later"]) {
        [[[LocalNotification alloc] init] setLocalNotificationWithMessage:_localNotification.alertBody
                                                                 fireDate:[NSDate dateWithTimeInterval:60*20 sinceDate:[NSDate date]]
                                                              repeatOrNot:NO
                                                                    sound:@"UILocalNotificationDefaultSoundName"
                                                                 setValue:@"PosponNotification" forKey:@"NotificationType" category:@"SleepNotification"];
    } else if ([identifier isEqualToString:@"night"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    completionHandler();
}

- (void)showSleepNotificationAlertView
{
    NSDictionary *userInfo = _localNotification.userInfo;
    if (![[userInfo objectForKey:@"NotificationType"] isEqualToString:@"提醒輸入起床時間"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睡前提醒"
                                                        message:_localNotification.alertBody
                                                       delegate:self
                                              cancelButtonTitle:@"我今天要熬夜，不要吵我！！"
                                              otherButtonTitles:@"知道了", @"稍後提醒", nil];
        [alert show];
    }
}

- (void)removeNotificationFromNotificationCenter
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            break;
        case 1:
            // Do nothing
            break;
        case 2:
            [[[LocalNotification alloc] init] setLocalNotificationWithMessage:_localNotification.alertBody
                                                                     fireDate:[NSDate dateWithTimeInterval:60*20 sinceDate:[NSDate date]]
                                                                  repeatOrNot:NO
                                                                        sound:@"UILocalNotificationDefaultSoundName"
                                                                     setValue:@"PosponNotification" forKey:@"NotificationType" category:@"SleepNotification"];
            break;
        default:
            break;
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Su.SleepTracker" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SleepTracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SleepTracker.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
