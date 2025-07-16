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

NSString* const butterflySdkVersion = @"2.1.0";

__strong static ButterflyHostController* _shared;

+ (ButterflyHostController*) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shared = [[ButterflyHostController alloc] initWithCoder:nil];
    });

    return _shared;
}

#pragma mark - Initialize

- (instancetype) init {
    return [ButterflyHostController shared];
}

- (instancetype) initWithCoder:(NSCoder*) coder {
    if(self = [super init]) {
        return self;
    }
    
    return nil;
}

#pragma mark - Interface Settings

+ (void)overrideLanguage:(NSString *) languageCode {
    [ButterflyHostController shared].languageCodeToOverride = languageCode;
}

+ (void)overrideCountry:(NSString *) countryCode {
    [ButterflyHostController shared].countryCodeToOverride = countryCode ?: @"n";
}

+ (void)useCustomColor:(NSString *) colorHexa {
    [ButterflyHostController shared].customColorHexa = colorHexa ?: @"n";
}

#pragma mark - Reporter Handling

+ (void)openReporterWithKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController:[ButterflyHostController topViewController]
                                                          usingKey:key];
}

- (void)openReporterInViewController:(UIViewController*)viewController
                            usingKey:(NSString*)key {
    NSString * languageCode = [self extractedLanguageCode];
    NSString* countryToOverride = self.countryCodeToOverride ?: @"n";
    NSString* customColorHexa = self.customColorHexa ?: @"n";

    NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-button.web.app/reporter/?language=%@&api_key=%@&sdk-version=%@&override_country=%@&colorize=%@&is-embedded-via-mobile-sdk=1", languageCode, key, butterflySdkVersion, countryToOverride, customColorHexa];

    [BFBrowser launchUrl:reporterUrl
                  result:^(id  _Nullable result) {
        [BFSDKLogger logMessage:@"Web page is loading..."];
    }];
}

// TODO: Why this?
+ (void)grabReportFromViewController:(UIViewController *)viewController
                            usingKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController:viewController
                                                          usingKey:key];
}

#pragma mark - Reporter Handling via deep link

+ (void)handleIncomingURL:(NSURL *)url
                   apiKey:(NSString *)apiKey {
    [[ButterflyHostController shared] handleIncomingURLInViewController:[ButterflyHostController topViewController]
                                                                    url:url
                                                                 apiKey:apiKey];
}

- (void)handleIncomingURLInViewController:(UIViewController*)viewController
                                      url:(NSURL *)url
                                   apiKey:(NSString *)apiKey {
    NSMutableDictionary<NSString *, NSString *> *urlParams = [self extractParamsFromURL:url];
    
    // extract the butterfly relevant params
    [BFBrowser fetchButterflyParamsFromURL:urlParams
                                completion:^(NSString * _Nullable butterflyParams) {
        NSString * languageCode = [self extractedLanguageCode];
        NSString* countryToOverride = self.countryCodeToOverride ?: @"n";
        NSString* customColorHexa = self.customColorHexa ?: @"n";

        NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-button.web.app/reporter/?language=%@&api_key=%@&sdk-version=%@&override_country=%@&colorize=%@&is-embedded-via-mobile-sdk=1&%@", languageCode, apiKey, butterflySdkVersion, countryToOverride, customColorHexa, butterflyParams];

        [BFBrowser launchUrl:reporterUrl
                      result:^(id  _Nullable result) {
            [BFSDKLogger logMessage:@"Web page is loading..."];
        }];
    }];
}

+ (void)handleUserActivity:(NSUserActivity *)userActivity
                    apiKey:(NSString *)apiKey {
    [[ButterflyHostController shared] handleUserActivityInViewController:[ButterflyHostController topViewController]
                                                            userActivity:userActivity
                                                                  apiKey:apiKey];
}

- (void)handleUserActivityInViewController:(UIViewController*)viewController
                              userActivity:(NSUserActivity *)userActivity
                                    apiKey:(NSString *)apiKey {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        NSMutableDictionary<NSString *, NSString *> *urlParams = [self extractParamsFromURL:url];

        // extract the butterfly relevant params
        [BFBrowser fetchButterflyParamsFromURL:urlParams
                                    completion:^(NSString * _Nullable butterflyParams) {
            NSString * languageCode = [self extractedLanguageCode];
            NSString* countryToOverride = self.countryCodeToOverride ?: @"n";
            NSString* customColorHexa = self.customColorHexa ?: @"n";

            NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-button.web.app/reporter/?language=%@&api_key=%@&sdk-version=%@&override_country=%@&colorize=%@&is-embedded-via-mobile-sdk=1&%@", languageCode, apiKey, butterflySdkVersion, countryToOverride, customColorHexa, butterflyParams];

            [BFBrowser launchUrl:reporterUrl
                          result:^(id  _Nullable result) {
                [BFSDKLogger logMessage:@"Web page is loading..."];
            }];
        }];
    }
}

+ (void)openURLContexts:(UIOpenURLContext *)urlContext
                 apiKey:(NSString *)apiKey {
    [[ButterflyHostController shared] openURLContextsInViewController:[ButterflyHostController topViewController]
                                                           urlContext:urlContext
                                                                 apiKey:apiKey];
}

- (void)openURLContextsInViewController:(UIViewController*)viewController
                             urlContext:(UIOpenURLContext *)urlContext
                                 apiKey:(NSString *)apiKey {
    NSURL *url = urlContext.URL;
    NSMutableDictionary<NSString *, NSString *> *urlParams = [self extractParamsFromURL:url];

    // extract the butterfly relevant params
    [BFBrowser fetchButterflyParamsFromURL:urlParams
                                completion:^(NSString * _Nullable butterflyParams) {
        NSString * languageCode = [self extractedLanguageCode];
        NSString* countryToOverride = self.countryCodeToOverride ?: @"n";
        NSString* customColorHexa = self.customColorHexa ?: @"n";

        NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-button.web.app/reporter/?language=%@&api_key=%@&sdk-version=%@&override_country=%@&colorize=%@&is-embedded-via-mobile-sdk=1&%@", languageCode, apiKey, butterflySdkVersion, countryToOverride, customColorHexa, butterflyParams];

        [BFBrowser launchUrl:reporterUrl
                      result:^(id  _Nullable result) {
            [BFSDKLogger logMessage:@"Web page is loading..."];
        }];
    }];
}

#pragma mark - Helpers

+ (UIViewController *)topViewController {
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

- (NSString *)extractedLanguageCode {
    NSString* languageCode;
    if (self.languageCodeToOverride && [self.languageCodeToOverride length] > 0) {
        languageCode = self.languageCodeToOverride;
    } else {
        // Device's language:  https://github.com/stefalda/ReactNativeLocalization/issues/178#issuecomment-581140974
        languageCode = [[[[[NSLocale preferredLanguages] objectAtIndex:0] componentsSeparatedByString:@"-"] firstObject] description];
        
        if (!languageCode) {
            //      if (!languageCode && @available(iOS 10.0, *)) { // Warning: @available does not guard availability here if (@available); use if (@available) instead
            if (@available(iOS 10.0, *)) {
                // App's language
                languageCode = [[NSLocale currentLocale] languageCode];
            } else {
                // Fallback on earlier versions
            }
        }
        
        if (!languageCode) {
            // App's localized string
            NSString* bundlePath = [[NSBundle bundleForClass:[BFUserInputHelper class]] pathForResource:@"TheButterflySDK"
                                                                                                 ofType:@"bundle"];
            NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
            languageCode = [[bundle localizedStringForKey:@"language_code"
                                                    value:@"EN"
                                                    table:nil] lowercaseString] ?: @"EN";
        }
    }
    return languageCode;
}

- (NSMutableDictionary<NSString *, NSString *> *)extractParamsFromURL:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> *items = components.queryItems;
    
    NSMutableDictionary<NSString *, NSString *> *params = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in items) {
        if (item.name && item.value) {
            params[item.name] = item.value;
        }
    }
    return params;
}

@end
