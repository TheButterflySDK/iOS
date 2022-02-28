//
//  BFViewController.m
//  TheButterflySDK
//
//  Created by Perry on 02/28/2022.
//  Copyright (c) 2022 Perry. All rights reserved.
//openReporterInViewController

#import "BFViewController.h"
#import "ButterflySDK.h"

@interface BFViewController ()

@end

@implementation BFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *btnOpenReporter = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 200, 100)];

    [btnOpenReporter setTitle:@"🦋" forState: UIControlStateNormal];
    [btnOpenReporter addTarget:self action: @selector(onOpenReporterClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnOpenReporter];
    btnOpenReporter.center = self.view.center;
}

- (void)onOpenReporterClicked: (UIButton *) sender {
    [ButterflySDK openReporterWithKey:@"your-api-key"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
