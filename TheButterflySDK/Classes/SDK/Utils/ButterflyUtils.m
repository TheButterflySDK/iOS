//
//  ButterflyUtils.m
//  The Butterfly SDK
//
//  Created by The Butterfly SDK on 01/01/2022.
//  Copyright © 2022 The Butterfly SDK. All rights reserved.
//

#import "ButterflyUtils.h"

@implementation BFSDKLogger : NSObject

+ (void)logMessage:(NSString *)message, ... {
    if (![ButterflyUtils isRunningReleaseVersion]) {
        // From: https://stackoverflow.com/a/4804807/2735029
        va_list args;
        va_start(args, message);
        NSLogv(message, args);
        va_end(args);
    }
}

@end

@interface ButterflyUtils()

@property (nonatomic, strong) NSString *libraryPath;
@property (nonatomic, strong) NSObject *appFinishedLaunchObserver;
@property (nonatomic) NSOperationQueue* bfGlobalOperationQueue;

@end

@implementation ButterflyUtils

@synthesize libraryPath;
@synthesize appFinishedLaunchObserver;
@synthesize bfGlobalOperationQueue;

// Singleton implementation in Objective-C
__strong static ButterflyUtils *_shared;
+ (ButterflyUtils *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[ButterflyUtils alloc] init];
    });
    
    return _shared;
}

- (id)init {
    if (self = [super init]) {
        bfGlobalOperationQueue = [[NSOperationQueue alloc] init];
    }

    return self;
}

+ (void) sendRequest:(NSDictionary *)jsonDictionary toUrl:(NSString *) urlString withHeaders:(NSDictionary *) headers completionCallback:(void (^)(NSString * _Nullable responseString)) completionCallback {
    NSMutableURLRequest *request = [ButterflyUtils prepareRequestWithBody: jsonDictionary forEndpoint: urlString];
    if (!completionCallback) {
        return;
    }

    if (!request) {
        completionCallback(@"");
        return;
    }

    for (NSObject *key in headers) {
        [request setValue: headers[key] forHTTPHeaderField: [key description]];
    }

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable returnedData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *returnString = [[NSString alloc] initWithData: returnedData encoding: NSUTF8StringEncoding];

        completionCallback(returnString);
    }];

    [task resume];
}

/**
 Using conditional compilation flags: https://miqu.me/blog/2016/07/31/xcode-8-new-build-settings-and-analyzer-improvements/
 */
+(BOOL)isRunningReleaseVersion {
#ifdef DEBUG
    return NO;
#else
    return YES;
#endif
}

+(BOOL)isRunningOnSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

-(void) onAppLoaded {
    // Wait for app to finish launch and then...
    appFinishedLaunchObserver = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidFinishLaunchingNotification object: nil queue: nil usingBlock:^(NSNotification * _Nonnull note) {

        [[NSNotificationCenter defaultCenter] removeObserver: [[ButterflyUtils shared] appFinishedLaunchObserver]];

    }];
}

-(NSString *) sdkLibraryPath {
    if (libraryPath != nil) {
        return libraryPath;
    }

    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"Butterfly"];

    BOOL isDir = YES;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath: path isDirectory: &isDir])
        if(![fileManager createDirectoryAtPath: path withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", path);


    libraryPath = path;

    return libraryPath;
}

+(NSString *) toJsonString:(NSDictionary *) jsonDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: jsonDictionary options: NSJSONWritingPrettyPrinted error: &error];

    NSString* jsonString = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
    NSLog(@"jsonString: %@", jsonString);
    
    return error ? nil : jsonString;
}

+(NSData *) toJsonData:(NSDictionary *) jsonDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: jsonDictionary options: NSJSONWritingPrettyPrinted error: &error];

    return jsonData;
}

+(NSDictionary *) toJsonDictionary:(NSString *) jsonString {
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: objectData
                                          options: NSJSONReadingMutableContainers
                                            error: &jsonError];

    return jsonDictionary;
}

+ (void)load {
    [[ButterflyUtils shared] onAppLoaded];
}

+(void)initialize {
//    NSLog(@"App loaded");
}

+ (NSMutableURLRequest *) prepareRequestWithBody:(NSDictionary *) bodyDictionary forEndpoint: (NSString *) apiEndpoint {
    NSData *postBody = [ButterflyUtils toJsonData: bodyDictionary];
    if (![postBody length]) {
        return nil;
    }

    NSMutableURLRequest *request = [ButterflyUtils prepareRequestWithEndpoint: apiEndpoint];

    [request setHTTPBody: postBody];

    return request;
}

+ (NSMutableURLRequest *) prepareRequestWithEndpoint:(NSString *) apiEndpoint {
    return [self prepareRequestWithEndpoint: apiEndpoint contentType: @"application/json; charset=utf-8"];
}

+ (NSMutableURLRequest *) prepareRequestWithEndpoint:(NSString *) serverUrlString contentType:(NSString *) contentType {
    if ([(serverUrlString ?: @"") length] == 0) return  nil;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: serverUrlString]];
    
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies: NO];
    [request setTimeoutInterval: 60];
    [request setHTTPMethod: @"POST"];
    
    [request setValue: contentType forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

+(void) pinToSuperView: (UIView *) subview attribute1:(NSLayoutAttribute) attribute1 attribute2:(NSLayoutAttribute) attribute2 {
    [ButterflyUtils pinToSuperView:subview attribute1:attribute1 constant1: 0.f attribute2:attribute2 constant2: 0.f];
}

+(void) pinToSuperView: (UIView *) subview attribute1:(NSLayoutAttribute) attribute1 constant1:(CGFloat)constant1 attribute2:(NSLayoutAttribute) attribute2 constant2:(CGFloat) constant2 {
    UIView *superview = [subview superview];
    if (superview == nil) return;

    subview.translatesAutoresizingMaskIntoConstraints = NO;

    [superview addConstraints:({
        @[ [NSLayoutConstraint
           constraintWithItem: subview
           attribute: attribute1
           relatedBy: NSLayoutRelationEqual
           toItem: superview
           attribute: attribute1
           multiplier:1.f constant: constant1],

           [NSLayoutConstraint
            constraintWithItem: subview
            attribute: attribute2
            relatedBy: NSLayoutRelationEqual
            toItem: superview
            attribute: attribute2
            multiplier:1.f constant: constant2] ];
    })];
}

+(void) pinToSuperViewCenter: (UIView *) subview {
    UIView *superview = [subview superview];
    if (superview == nil) return;

    subview.translatesAutoresizingMaskIntoConstraints = NO;

    [superview addConstraints:({
        @[ [NSLayoutConstraint
           constraintWithItem: subview
           attribute:NSLayoutAttributeCenterX
           relatedBy:NSLayoutRelationEqual
           toItem: superview
           attribute:NSLayoutAttributeCenterX
           multiplier:1.f constant:0.f],

           [NSLayoutConstraint
            constraintWithItem: subview
            attribute:NSLayoutAttributeCenterY
            relatedBy:NSLayoutRelationEqual
            toItem: superview
            attribute:NSLayoutAttributeCenterY
            multiplier:1.f constant:0.f] ];
    })];
}

+(void) stretchToSuperView: (UIView *) subview {
    UIView *superview = [subview superview];
    if (superview == nil) return;

    subview.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *width =[NSLayoutConstraint
                                        constraintWithItem: subview
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:0
                                        toItem: superview
                                        attribute:NSLayoutAttributeWidth
                                        multiplier:1.0
                                        constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                         constraintWithItem: subview
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:0
                                         toItem: superview
                                         attribute:NSLayoutAttributeHeight
                                         multiplier:1.0
                                         constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                                       constraintWithItem: subview
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem: superview
                                       attribute:NSLayoutAttributeTop
                                       multiplier:1.0f
                                       constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                           constraintWithItem: subview
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem: superview
                                           attribute:NSLayoutAttributeLeading
                                           multiplier:1.0f
                                           constant:0.f];
    [superview addConstraint:width];
    [superview addConstraint:height];
    [superview addConstraint:top];
    [superview addConstraint:leading];
}

@end
