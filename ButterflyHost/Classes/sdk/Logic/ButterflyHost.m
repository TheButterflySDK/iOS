//
//  ButterflyHostController.m
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "ButterflyHost.h"
#import "ButterflyHostController.h"

@implementation ButterflyHost

__strong static ButterflyHost* _shared;
+(ButterflyHost*) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shared = [[ButterflyHost alloc]initWithCoder:nil];
    });
    return _shared;
}

-(instancetype) init {
    return [ButterflyHost shared];
}

-(instancetype)initWithCoder:(NSCoder*) coder {
   if(self = [super init]) { }
    
    return self;
}

+(void) grabReportWithKey:(NSString *)key {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ButterflyHostController grabReportWithKey:key];
    }];
}

@end
