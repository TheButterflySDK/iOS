//
//  ButterflyHostController.m
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "ButterflyHostController.h"
#import "BFBrowser.h"
#import "BFUserInputHelper.h"
#import "BFToastMessage.h"
#import "BFBrowser.h"

@implementation ButterflyHostController

__strong static ButterflyHostController* _shared;
+(ButterflyHostController*) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shared = [[ButterflyHostController alloc] initWithCoder:nil];
    });

    return _shared;
}

-(instancetype) init {
    return [ButterflyHostController shared];
}

-(instancetype) initWithCoder:(NSCoder*) coder {
    if(self = [super init]) {
        return self;
    }
    
    return nil;
}

+ (void)grabReportFromViewController:(UIViewController *)viewController usingKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController: viewController usingKey: key];
}

-(void) openReporterInViewController:(UIViewController*) viewController usingKey:(NSString*) key {
    NSString* bundlePath = [[NSBundle bundleForClass:[BFUserInputHelper class]]
                      pathForResource:@"Butterfly" ofType:@"bundle"];
    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    NSString* languageCode = [[bundle localizedStringForKey:@"language_code" value:@"EN" table:nil] lowercaseString] ?: @"EN";
    NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-host.web.app/reporter/?language=%@&api_key=%@&is-embedded-via-mobile-sdk=1", languageCode, key];

    [BFBrowser launchURLInViewController: reporterUrl result:^(id  _Nullable result) {
        NSLog(@"URL launched!");
    }];
}

+ (void)openReporterWithKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController:
     [ButterflyHostController topViewController] usingKey:key];
}

+ (UIViewController *) topViewController {
    return [self topViewControllerFromViewController:
            [UIApplication sharedApplication].keyWindow.rootViewController];
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
+ (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self
                topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
    }

    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)viewController;
        return [self topViewControllerFromViewController:tabController.selectedViewController];
    }

    if (viewController.presentedViewController) {
        return [self topViewControllerFromViewController:viewController.presentedViewController];
    }

    return viewController;
}

@end
