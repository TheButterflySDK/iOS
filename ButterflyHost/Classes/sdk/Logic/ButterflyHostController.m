//
//  ButterflyHostController.m
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "ButterflyHostController.h"
#import "BFReport.h"
#import "BFBrowser.h"
#import "BFUserInputHelper.h"
#import <Reachability/Reachability.h>
#import "BFToastMessage.h"
#import "BFBrowser.h"

@implementation ButterflyHostController

__strong static ButterflyHostController* _shared;
+(ButterflyHostController*) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shared = [[ButterflyHostController alloc] initWithCoder:nil];
    });

    return _shared;
}

-(instancetype) init {
    return [ButterflyHostController shared];
}

-(instancetype) initWithCoder:(NSCoder*) coder {
    if(self = [super init]) {
        return self;
    }
    
    return nil;
}

+ (void)grabReportFromViewController:(UIViewController *)viewController usingKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController: viewController usingKey: key];
}

-(void) openReporterInViewController:(UIViewController*) viewController usingKey:(NSString*) key {
    NSString* bundlePath = [[NSBundle bundleForClass:[BFUserInputHelper class]]
                      pathForResource:@"Butterfly" ofType:@"bundle"];
    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    NSString* languageCode = [[bundle localizedStringForKey:@"language_code" value:@"EN" table:nil] lowercaseString];
    NSString* reporterUrl = [NSString stringWithFormat:@"https://butterfly-host.web.app/reporter/?language=%@&api_key=%@&is-embedded-via-mobile-sdk=1", languageCode, key];
    // https://butterfly-host.web.app/reporter/?language=he&api_key=test&is-embedded-via-mobile-sdk=1

    [BFBrowser launchURLInViewController: reporterUrl result:^(id  _Nullable result) {
        NSLog(@"URL launched!");
    }];
}

-(BOOL) isNetwokAvailable {
    Reachability *_reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [_reachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

-(void)post:(NSString*) url relevantReport:(BFReport*) report usingKey:(NSString *) key {
    NSDictionary *jsonBodyDict = @{@"fakePlace":report.fakePlace,@"wayContact": report.contactDetails, @"comments": report.comments};
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonBodyData];
    //adding the api key to header
    [request addValue: key forHTTPHeaderField:@"BUTTERFLY_HOST_API_KEY"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
        NSInteger statusCode = 500;
        if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
            statusCode = httpResponse.statusCode;
        }

        NSString* bundlePath = [[NSBundle bundleForClass:[BFUserInputHelper class]] pathForResource:@"Butterfly" ofType:@"bundle"];
        NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
        
        [bundle localizedStringForKey:@"butterfly_no_internet" value:@"" table:nil];

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"קיבלנו"
                            message: @"סודיותך מובטחת! נציגה מטעמנו תיצור איתך קשר דיסקרטי. תוכלי לזהות אותה כי היא תגיד לך שהיא מפרויקט הפרפר או מהמקום שאת ציינת בפנייתך זו."
                            preferredStyle: UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"פרטים נוספים" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [BFBrowser launchURLInViewController:@"https://butterfly-host.web.app/send-report/more-info.html" result:^(id  _Nullable result) {
                NSLog(@"yo!");
            }];
        }]];

        switch (statusCode) {
            case 200:
                [[ButterflyHostController topViewController] presentViewController: alertController animated:YES completion: nil];
                [BFToastMessage show:[bundle localizedStringForKey:@"butterfly_success" value:@"" table:nil] delayInSeconds:3 onDone:nil];
                break;
            case 403:
                [BFToastMessage show:[bundle localizedStringForKey:@"butterfly_host_API_KEY_not_valid" value:@"" table:nil] delayInSeconds:3 onDone:nil];
                break;
            default:
                [BFToastMessage show:
                 [bundle localizedStringForKey:@"butterfly_failed" value:@"" table:nil]
                    delayInSeconds:3 onDone:nil];
                break;
        }
    }];
    
    [task resume];
}

+ (void)grabReportWithKey:(NSString *)key {
    [[ButterflyHostController shared] openReporterInViewController:
     [ButterflyHostController topViewController] usingKey:key];
}

+ (UIViewController *)topViewController {
    return [self topViewControllerFromViewController:
            [UIApplication sharedApplication].keyWindow.rootViewController];
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
+ (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self
                topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
    }

    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)viewController;
        return [self topViewControllerFromViewController:tabController.selectedViewController];
    }

    if (viewController.presentedViewController) {
        return [self topViewControllerFromViewController:viewController.presentedViewController];
    }

    return viewController;
}

@end
