//
//  ViewController.m
//  Example
//
//  Created by Assaf Tayouri on 31/08/2025.
//

#import "ViewController.h"
#import "TheButterflySDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ButterflySDK useCustomColor:@"00ff00"];
}

- (IBAction)onButterflyClick:(UIButton *)sender {
    [ButterflySDK openReporterWithKey:@"your-api-key"];
}


@end
