//
//  ButterflySDK.h
//  butterfly
//
//  Created by Aviel on 11/17/20. Modified by Perry on 01/03/22
//  Copyright © 2020 Aviel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButterflySDK: NSObject

#pragma mark - Interface Settings

/**
 Sets the main user interface's language, no matter what's the language of the user's device.

 In general the language is detected according to the deivice settings. At this moment, the SDK recognizes only two languages (Hebrew or English).
 In case the language is not supported - the SDK will operate in English.
 
 This method will override the detected language and will operate in English or in Hebrew.
 */
+ (void) overrideLanguage:(NSString *)languageToOverride;
/**
 Sets a two letter country code of the reporter's location, that will be used in the Butterfly servers, no matter where it was really sent from.
 */
+ (void) overrideCountry:(NSString *)countryCode;

/**
 Sets a new color theme of the Butterfly's screens. The string represents the hexadecimal value of the color. Examples of possible formats: "0xFF91BA48", "FF91BA48", "91BA48"
 */
+ (void)useCustomColor:(NSString *)colorHexa;

#pragma mark - Reporter Handling

+ (void)openReporterWithKey:(NSString*)key;

+ (void)handleIncomingURL:(NSURL *)url
                   apiKey:(NSString *)apiKey;

+ (void)handleUserActivity:(NSUserActivity *)userActivity;


+ (void)openURLContexts:(NSSet<UIOpenURLContext *> *)urlContext
                 apiKey:(NSString *)apiKey API_AVAILABLE(ios(13.0));
@end
