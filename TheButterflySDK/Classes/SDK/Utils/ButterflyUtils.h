//
//  ButterflyUtils.h
//  The Butterfly SDK
//
//  Created by The Butterfly SDK on 01/01/2022.
//  Copyright © 2022 The Butterfly SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A private class that is responsible on our core actions.
 */
@interface ButterflyUtils: NSObject

+(BOOL)isRunningReleaseVersion;
+(BOOL)isRunningOnSimulator;

+ (void)sendRequest:(NSDictionary *)jsonDictionary toUrl:(NSString *)urlString withHeaders:(NSDictionary *)headers completionCallback:(void (^)(NSString * responseString)) completionCallback;

+(NSData *) toJsonData:(NSDictionary *) jsonDictionary;
+(NSDictionary *) toJsonDictionary:(NSString *) jsonString;

@end
