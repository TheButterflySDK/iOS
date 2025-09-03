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
#import "ButterflyUtils.h"

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
    [[ButterflyHostController shared] openReporterUsingKey:key extraParams:nil];
}

#pragma mark - Reporter Handling via deep link

+ (void)handleIncomingURL:(NSURL *)url
                   apiKey:(NSString *)apiKey {
    [[ButterflyHostController shared] handleURL:url
                                         apiKey:apiKey];
}

+ (void)handleUserActivity:(NSUserActivity *)userActivity
                    apiKey:(NSString *)apiKey {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        [[ButterflyHostController shared] handleURL:url
                                             apiKey:apiKey];
    }
}

+ (void)openURLContexts:(UIOpenURLContext *)urlContext
                 apiKey:(NSString *)apiKey {
    [[ButterflyHostController shared] handleURL:urlContext.URL
                                         apiKey:apiKey];
}

- (void)handleURL:(NSURL *)url
           apiKey:(NSString *)apiKey {
    NSMutableDictionary<NSString *, NSString *> *urlParams = [self extractParamsFromURL:url];
    
    if (![urlParams count]) return;
    
    [BFBrowser fetchButterflyParamsFromURL:urlParams
                                    appKey:apiKey
                                sdkVersion:butterflySdkVersion
                                completion:^(NSDictionary * _Nullable butterflyParams) {
        [ButterflyHostController whenTopViewControllerIsReady:^(BOOL success) {
            if (!success) return;
            
            if ([butterflyParams count]) {
                [self openReporterUsingKey:apiKey
                               extraParams:butterflyParams];
            } else {
                [BFSDKLogger logMessage: @"No need to handle deep link params. Aborting URL handling..."];
            }
        }];
    }];
}

#pragma mark - Shared logic

- (void)openReporterUsingKey:(NSString *)key
                 extraParams:(NSDictionary * _Nullable) extraParams {
    
    NSString* languageCode = [self extractedLanguageCode];
    NSString* countryToOverride = self.countryCodeToOverride ?: @"n";
    NSString* customColorHexa = self.customColorHexa ?: @"n";
    NSString* bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSMutableDictionary *allParams = [NSMutableDictionary new];
    NSString* reporterUrl = @"https://butterfly-button.web.app/reporter/";

    [allParams setObject: languageCode forKey: @"language"];
    [allParams setObject: key forKey: @"api_key"];
    [allParams setObject: butterflySdkVersion forKey: @"sdk-version"];
    [allParams setObject: countryToOverride forKey: @"override_country"];
    [allParams setObject: customColorHexa forKey: @"colorize"];
    [allParams setObject: @"1" forKey: @"is-embedded-via-mobile-sdk"];
    [allParams setObject: bundleId forKey: @"mobile-app-id"];
    
    if ([extraParams count]) {
        // Add / Override vales
        [allParams addEntriesFromDictionary: extraParams];
    }

    NSString* wholeQueryString = [self extractURLExtraParamsFromDictionary: allParams];
    
    if (![wholeQueryString length]) return;;
    
    reporterUrl = [reporterUrl stringByAppendingFormat:@"?%@", wholeQueryString];

    [ButterflyUtils runOnMainThread: ^{
        [BFBrowser launchUrl:reporterUrl
                      result:^(id _Nullable result) {
            [BFSDKLogger logMessage:@"Web page is loading..."];
        }];
    }];
}

#pragma mark - Helpers

+ (void)whenTopViewControllerIsReady:(void (^)(BOOL success))completion {
    [ButterflyUtils runOnMainThread:^{
        NSMutableArray<UIViewController *> *topViewControllerHistory = @[[ButterflyHostController topViewController]].mutableCopy;

        [ButterflyUtils repeatUntil:0.5
                        maxAttempts:6
                      exitCondition:^BOOL {
            UIViewController *currentTop = [ButterflyHostController topViewController];

            if (!currentTop) {
                return NO;
            }
            
            if ([topViewControllerHistory.lastObject isEqual:currentTop]) {
                return YES;
            }

            [topViewControllerHistory addObject:currentTop];
            
            return NO;
        } completion:^(BOOL success) {
            if (success) {
                [BFSDKLogger logMessage:@"✅ TopViewController ready. Proceeding with URL param handling."];
            } else {
                [BFSDKLogger logMessage:@"❌ Timed out waiting for TopViewController. Aborting URL param handling."];
            }
            
            completion(success);
        }];
    }];
}

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
    NSMutableDictionary<NSString *, NSString *> *params = [NSMutableDictionary dictionary];

    if (![[url absoluteString] length]) {
        return params;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> *items = components.queryItems;
    
    for (NSURLQueryItem *item in items) {
        if (!item) continue;
        
        if (item.name && item.value) {
            params[item.name] = item.value;
        }
    }

    return params;
}

- (NSString *)extractURLExtraParamsFromDictionary:(NSDictionary * _Nullable)resultParams {
    NSMutableArray *queryItems = [NSMutableArray array];
    
    if (!resultParams || resultParams.count == 0) {
        return @"";
    }
    
    for (NSString *key in resultParams) {
        NSString *value = [resultParams objectForKey:key];

        // Percent-encode both key and value
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        NSString *item = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [queryItems addObject:item];
    }

    // Join all key=value pairs with &
    NSString *urlParams = [queryItems componentsJoinedByString:@"&"];
    
    return urlParams;
}

@end
