// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import "BFBrowser.h"
#import "ButterflyHostController.h"
#import "ButterflyUtils.h"

@interface BFBrowserNavigationController: UINavigationController<UIAdaptivePresentationControllerDelegate>

@end

@implementation BFBrowserNavigationController

- (BOOL)presentationControllerShouldDismiss:(UIPresentationController *)presentationController {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
}

@end

@interface BFBrowserViewController: UIViewController <WKNavigationDelegate, WKScriptMessageHandler>

@property(strong, nonatomic) NSURL *url;
@property(strong, nonatomic) WKWebView *webView;

@end

@implementation BFBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame: CGRectZero configuration:[self wkWebViewConfiguration]];
    self.webView.navigationDelegate = self;

    [self.view addSubview: self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL: self.url]];
    self.webView.allowsBackForwardNavigationGestures = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.webView.frame = self.view.frame; // TODO: Use autolayout programmatically
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *navigationUrlString = navigationAction.request.URL.absoluteURL.absoluteString;
    NSLog(@"%@", navigationUrlString);

    BOOL shouldNavigate = [navigationUrlString hasPrefix:@"https://butterfly-host.web.app"];
    
    decisionHandler(shouldNavigate ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
    
    NSString *messageProtocolPrefix = @"https://the-butterfly.bridge/";
    BOOL didSendMessage = [navigationUrlString hasPrefix: messageProtocolPrefix];
    if (didSendMessage) {
        [self onMessageFromWebPage: [navigationUrlString stringByReplacingOccurrencesOfString: messageProtocolPrefix withString: @""]];
    }
}

-(WKWebViewConfiguration *) wkWebViewConfiguration {
    WKUserContentController *userController = [WKUserContentController new];
    [userController addScriptMessageHandler: self name:@"iosJavascriptInterface"];
            
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userController;
    return configuration;
}

- (void)onMessageFromWebPage:(NSString *)message {
    if ([message isEqualToString:@"cancel"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Unhandled butterfly message: %@", message);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    BOOL didHandleMessage = NO;
    if ([[message body] isKindOfClass: [NSDictionary class]]) {
        NSMutableDictionary *commandFromJs = [NSMutableDictionary dictionaryWithDictionary: [message body]];
        if ([[commandFromJs valueForKey:@"commandName"] isEqual:@"sendRequest"] && [commandFromJs valueForKey:@"urlString"]) {
            NSString *urlString = [[commandFromJs valueForKey:@"urlString"] description];
            NSString *apiKey = [[commandFromJs valueForKey:@"key"] description];
            
            NSString *commandId = [[commandFromJs valueForKey:@"commandId"] description];
            if (!commandId) {
                commandId = @"";
            }

            [commandFromJs removeObjectForKey:@"key"];
            [commandFromJs removeObjectForKey:@"urlString"];
            [commandFromJs removeObjectForKey:@"commandId"];
            [commandFromJs removeObjectForKey:@"commandName"];

            __weak __typeof__(self) weakSelf = self;

            [ButterflyUtils sendRequest:[NSDictionary dictionaryWithDictionary: commandFromJs] toUrl:urlString withHeaders:@{@"butterfly_host_api_key": apiKey} completionCallback:^(NSString *responseString) {
                if (![ButterflyUtils isRunningReleaseVersion]) {
                    NSLog(@"%@", responseString);
                }

                if (![responseString isEqualToString: @"OK"]) {
                    responseString = @"error";
                }

                NSString* jsCommand = [NSString stringWithFormat: @"bfPureJs.commandResults['%@'] = '%@';", commandId, responseString];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    __strong __typeof__(self) strongSelf = weakSelf;
                    [[strongSelf webView] evaluateJavaScript: jsCommand completionHandler:^(id _Nullable jsResult, NSError * _Nullable error) {
                        if (error && ![ButterflyUtils isRunningReleaseVersion]) {
                            NSLog(@"%@", error);
                        }
                    }];
                }];
            }];

            didHandleMessage = YES;
        }
    }
    
    if (!didHandleMessage) {
        NSLog(@"Unhandled butterfly message: %@", message);
    }
}

@end

API_AVAILABLE(ios(9.0))
@interface BFBrowserURLSession: NSObject <SFSafariViewControllerDelegate>

@property(copy, nonatomic) BFBrowserResult browserResult;
@property(strong, nonatomic) NSURL *url;
@property(strong, nonatomic) SFSafariViewController *safari;
@property(nonatomic, copy) void (^didFinish)(void);

@end

@implementation BFBrowserURLSession

@end

API_AVAILABLE(ios(9.0))
@interface BFBrowser()

@property(strong, nonatomic) BFBrowserURLSession *currentSession;

@end

@implementation BFBrowser

- (BOOL)canLaunchURL:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  UIApplication *application = [UIApplication sharedApplication];
  return [application canOpenURL:url];
}

- (void)launchURL:(NSString *)urlString
           result:(BFBrowserResult)result {
    NSURL *url = [NSURL URLWithString:urlString];
    UIApplication *application = [UIApplication sharedApplication];
    
    if (@available(iOS 10.0, *)) {
        NSNumber *universalLinksOnly = @0; //@1 ?: @0;
        NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly : universalLinksOnly};
        [application openURL:url
                     options:options
           completionHandler:^(BOOL success) {
            result(@(success));
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BOOL success = [application openURL:url];
#pragma clang diagnostic pop
        result(@(success));
    }
}

+ (void)launchURLInViewController:(NSString *)url result:(BFBrowserResult)result {
    [[[BFBrowser alloc] init] launchURLInVC: url result:result];
}

- (void)launchURLInVC:(NSString *) urlString result:(BFBrowserResult) result {
    NSURL *url = [NSURL URLWithString:urlString];
    BFBrowserViewController *browserViewController = [[BFBrowserViewController alloc] init];
    browserViewController.url = url;
    
    BFBrowserNavigationController *browserNavigationController = [[BFBrowserNavigationController alloc] initWithRootViewController:browserViewController];
    browserNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [[ButterflyHostController topViewController] presentViewController: browserNavigationController
                                                              animated:YES
                                                            completion:nil];
}

@end
