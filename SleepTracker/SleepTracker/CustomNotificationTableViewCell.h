//
//  CustomNotificationTableViewCell.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/28.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fireDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;

@end
