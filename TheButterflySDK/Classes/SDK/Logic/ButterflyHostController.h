//
//  ButterflyHostController.h
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ButterflyHostController: NSObject

+ (void)overrideLanguage:(NSString *)languageCode;
+ (void)overrideCountry:(NSString *)countryCode;
+ (void)useCustomColor:(NSString *)colorHexa;

+ (void)openReporterWithKey:(NSString *)key;


+ (void)handleIncomingURL:(NSURL *)url
                   apiKey:(NSString *)apiKey;

+ (void)handleUserActivity:(NSUserActivity *)userActivity
                    apiKey:(NSString *)apiKey;

+ (void)openURLContexts:(UIOpenURLContext *)urlContext
                 apiKey:(NSString *)apiKey API_AVAILABLE(ios(13.0));

+ (UIViewController *)topViewController;

@end
