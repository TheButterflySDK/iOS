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

@interface ButterflyHostController()

@property (nonatomic, assign) NSString *languageCodeToOverride;
@property (nonatomic, strong) NSString *countryCodeToOverride;
@property (nonatomic, strong) NSString *customColorHexa;

@end

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

+ (void)openReporterWithKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController:
     [ButterflyHostController topViewController] usingKey:key];
}

+ (void)overrideLanguage:(NSString *) languageCode {
    [ButterflyHostController shared].languageCodeToOverride = languageCode;
}

+ (void)overrideCountry:(NSString *) countryCode {
    [ButterflyHostController shared].countryCodeToOverride = countryCode ?: @"n";
}

+ (void)useCustomColor:(NSString *) colorHexa {
    [ButterflyHostController shared].customColorHexa = colorHexa ?: @"n";
}

+ (void)grabReportFromViewController:(UIViewController *)viewController usingKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController: viewController usingKey: key];
}

-(void) openReporterInViewController:(UIViewController*) viewController usingKey:(NSString*) key {
    NSString* languageCode;
    if (self.languageCodeToOverride && [self.languageCodeToOverride length] > 0) {
        languageCode = self.languageCodeToOverride;
    } else {
        NSString* bundlePath = [[NSBundle bundleForClass:[BFUserInputHelper class]] pathForResource:@"TheButterflySDK" ofType:@"bundle"];
        NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
        languageCode = [[bundle localizedStringForKey:@"language_code" value:@"EN" table:nil] lowercaseString] ?: @"EN";
    }

    NSString* countryToOverride = self.countryCodeToOverride ?: @"n";

    NSString* butterflySdkVersion = @"1.1.0";
    NSString* customColorHexa = self.customColorHexa ?: @"n";

    NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-host.web.app/reporter/?language=%@&api_key=%@&sdk-version=%@&override_country=%@&colorize=%@&is-embedded-via-mobile-sdk=1", languageCode, key, butterflySdkVersion, countryToOverride, customColorHexa];

    [BFBrowser launchURLInViewController: reporterUrl result:^(id  _Nullable result) {
        NSLog(@"URL launched!");
    }];
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
