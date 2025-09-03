//
//  ButterflySDK.m
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "ButterflySDK.h"
#import "ButterflyHostController.h"
#import "ButterflyUtils.h"

@implementation ButterflySDK

__strong static ButterflySDK* _shared;
+ (ButterflySDK*) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shared = [[ButterflySDK alloc] initWithCoder:nil];
    });
    return _shared;
}

#pragma mark - Initialize

- (instancetype)init {
    return [ButterflySDK shared];
}

- (instancetype)initWithCoder:(NSCoder*)coder {
   if(self = [super init]) { }
    
    return self;
}

#pragma mark - Interface Settings

+ (void)overrideLanguage:(NSString *)languageToOverride {
    [ButterflyHostController overrideLanguage:languageToOverride];
}

+ (void)overrideCountry:(NSString *)countryCode {
    [ButterflyHostController overrideCountry:countryCode];
}

+ (void)useCustomColor:(NSString *)colorHexa {
    [ButterflyHostController useCustomColor:colorHexa];
}

#pragma mark - Reporter Handling

+ (void)openWithKey:(NSString *)key {
    [ButterflyHostController openReporterWithKey:key];
}

+ (void)openReporterWithKey:(NSString *)key {
    [self openWithKey: key];
}

+ (void)handleIncomingURL:(NSURL *)url
                   apiKey:(NSString *)apiKey {
    [ButterflyHostController handleIncomingURL:url apiKey:apiKey];
}

+ (void)handleUserActivity:(NSUserActivity *)userActivity
                    apiKey:(NSString *)apiKey {
    [ButterflyHostController handleUserActivity:userActivity apiKey:apiKey];
}

+ (void)openURLContexts:(UIOpenURLContext *)urlContext
                 apiKey:(NSString *)apiKey {
    [ButterflyHostController openURLContexts:urlContext apiKey:apiKey];
}

@end
