//
//  ButterflyUtils.m
//  The Butterfly SDK
//
//  Created by The Butterfly SDK on 01/01/2022.
//  Copyright © 2022 The Butterfly SDK. All rights reserved.
//

#import "ButterflyUtils.h"

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

+ (void)sendRequest:(NSDictionary *)jsonDictionary toUrl:(NSString *) urlString withHeaders:(NSDictionary *) headers completionCallback:(void (^)(NSString * _Nullable responseString)) completionCallback {
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

@end
