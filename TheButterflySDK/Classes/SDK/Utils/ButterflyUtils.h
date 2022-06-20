//
//  ButterflyUtils.h
//  The Butterfly SDK
//
//  Created by The Butterfly SDK on 01/01/2022.
//  Copyright © 2022 The Butterfly SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFSDKLogger: NSObject

//+(void) logMessage: (NSString *) message;
//+(void) logMessage: (NSString *) NSString *format, ...;
+(void) logMessage:(NSString *)message, ...;

@end

/**
 A private class that is responsible on our core actions.
 */
@interface ButterflyUtils: NSObject

+(BOOL)isRunningReleaseVersion;
+(BOOL)isRunningOnSimulator;

+ (void)sendRequest:(NSDictionary *)jsonDictionary toUrl:(NSString *)urlString withHeaders:(NSDictionary *)headers completionCallback:(void (^)(NSString * responseString)) completionCallback;

+(NSData *) toJsonData:(NSDictionary *) jsonDictionary;
+(NSDictionary *) toJsonDictionary:(NSString *) jsonString;

+(void) pinToSuperView: (UIView *) subview attribute1:(NSLayoutAttribute) attribute1 attribute2:(NSLayoutAttribute) attribute2;
+(void) pinToSuperView: (UIView *) subview attribute1:(NSLayoutAttribute) attribute1 constant1:(CGFloat) constant1 attribute2:(NSLayoutAttribute) attribute2  constant2:(CGFloat) constant2;
+(void) pinToSuperViewCenter: (UIView *) subview;
+(void) stretchToSuperView: (UIView *) subview;

@end
