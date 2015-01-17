//
//  StatisticViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2014/12/26.
//  Copyright (c) 2014年 蘇健豪. All rights reserved.
//

#import "StatisticViewController.h"

@interface StatisticViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *goToBedTimeMaxLabel;

@property (weak, nonatomic) IBOutlet UILabel *wakeUpTimeMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *wakeUpTimeAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *wakeUpTimeMaxLabel;

@property (weak, nonatomic) IBOutlet UILabel *sleepTimeMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeMaxLabel;


@end

@implementation StatisticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end