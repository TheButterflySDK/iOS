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
+(ButterflySDK*) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shared = [[ButterflySDK alloc]initWithCoder:nil];
    });
    return _shared;
}

-(instancetype) init {
    return [ButterflySDK shared];
}

-(instancetype)initWithCoder:(NSCoder*) coder {
   if(self = [super init]) { }
    
    return self;
}

+(void) openReporterWithKey:(NSString *)key {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ButterflyHostController openReporterWithKey:key];
    }];
}

+ (void)overrideLanguage:(BFInterfaceLanguage)languageToOverride {
    switch (languageToOverride) {
        case BFInterfaceLanguage_Hebrew:
            [ButterflyHostController overrideLanguage: @"he"];
            break;
        case BFInterfaceLanguage_English:
            [ButterflyHostController overrideLanguage: @"en"];
            break;
        default:
            if (![ButterflyUtils isRunningReleaseVersion]) {
                NSLog(@"ButterflySDK: Used unsupported language");
            }
            break;
    }
    
}

+ (void)overrideCountry:(NSString *)countryCode {
    [ButterflyHostController overrideCountry: countryCode];
}

+ (void)useCustomColor:(NSString *) colorHexa {
    [ButterflyHostController useCustomColor: colorHexa];
}

@end
