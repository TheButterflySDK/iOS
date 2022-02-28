//
//  ButterflySDK.m
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "ButterflySDK.h"
#import "ButterflyHostController.h"

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

@end
