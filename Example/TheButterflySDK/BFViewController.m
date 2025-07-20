//
//  BFViewController.m
//  TheButterflySDK
//
//  Created by Perry on 02/28/2022.
//  Copyright (c) 2022 Perry. All rights reserved.
//
//  openReporterInViewController

#import "BFViewController.h"
#import "BFAppDelegate.h"
#import "ButterflySDK.h"

@interface BFViewController ()

@end

@implementation BFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [ButterflySDK useCustomColor:@"00ff00"];
}

- (IBAction)onButterflyClick:(UIButton *)sender {
    [ButterflySDK openReporterWithKey:@"your-api-key"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
