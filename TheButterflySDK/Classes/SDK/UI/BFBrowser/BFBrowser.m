// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import "BFBrowser.h"
#import "ButterflyHostController.h"

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
@property (nonatomic, strong) NSObject *appGoesBackgroundObserver;

@end

@implementation BFBrowserViewController

__strong static NSMutableSet *_urlWhiteList;

+(NSMutableSet *) urlWhiteList {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _urlWhiteList = [NSMutableSet set];
    });

    return _urlWhiteList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame: CGRectZero configuration:[self wkWebViewConfiguration]];
    self.webView.navigationDelegate = self;

    [self.view addSubview: self.webView];
    [ButterflyUtils stretchToSuperView: self.webView];

    UIButton *closeButton;
    if (@available(iOS 13.0, *)) {
        closeButton = [UIButton buttonWithType: UIButtonTypeClose];
    } else {
        closeButton = [UIButton buttonWithType: UIButtonTypeSystem];
        [closeButton setTitle: @"❌" forState:UIControlStateNormal];
    }

    [closeButton addTarget: self action:@selector(onCloseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: closeButton];
    [ButterflyUtils pinToSuperView: closeButton attribute1: NSLayoutAttributeTrailing constant1: -10 attribute2: NSLayoutAttributeTop constant2: 60];

    [self.webView loadRequest:[NSURLRequest requestWithURL: self.url]];
    self.webView.allowsBackForwardNavigationGestures = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    __weak __typeof__(self) weakSelf = self;
    self.appGoesBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationWillResignActiveNotification object: nil queue: nil usingBlock:^(NSNotification * _Nonnull note) {
//        [weakSelf dismissAll];
    }];
}

- (void)dismissAll {
    [self beGone:^{
        if ([[ButterflyHostController topViewController] isKindOfClass: [BFBrowserViewController class]]) {
            BFBrowserViewController *top = (BFBrowserViewController *) [ButterflyHostController topViewController];
            [top dismissAll];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];

    [[NSNotificationCenter defaultCenter] removeObserver: [self appGoesBackgroundObserver]];
}

-(BOOL) isWhiteListed:(NSString *) urlString {
    if ([urlString hasPrefix:@"https://butterfly-button.web.app"]) return YES;
    if ([urlString hasPrefix:@"https://butterfly-host.web.app"]) return YES;

    for (NSString *whiteListed in BFBrowserViewController.urlWhiteList) {
        if ([urlString hasPrefix: whiteListed]) return YES;
    }

    return NO;
}

-(void) onCloseButtonPressed:(UIButton *) sender {
    [self beGone: nil];
}

-(void) beGone:(void (^ __nullable)(void)) onDone {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (onDone) {
            onDone();
        }
    }];
}

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *navigationUrlString = navigationAction.request.URL.absoluteURL.absoluteString;
    [BFSDKLogger logMessage: @"navigationUrlString: %@", navigationUrlString];

    BOOL shouldNavigate = [self isWhiteListed: navigationUrlString];
    
    decisionHandler(shouldNavigate ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
    
    NSString *messageProtocolPrefix = @"https://the-butterfly.bridge/";
    BOOL didReceiveMessageFromWebView = [navigationUrlString hasPrefix: messageProtocolPrefix];
    if (didReceiveMessageFromWebView) {
        [self onMessageFromWebPage: [navigationUrlString stringByReplacingOccurrencesOfString: messageProtocolPrefix withString: @""]];
    }
}

-(WKWebViewConfiguration *) wkWebViewConfiguration {
    // from iOS 8.0+, https://developer.apple.com/documentation/webkit/wkusercontentcontroller
    WKUserContentController *userController = [WKUserContentController new];
    [userController addScriptMessageHandler: self name:@"iosJavascriptInterface"];
            
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userController;
    return configuration;
}


- (void)onMessageFromWebPage:(NSString *) message {
    NSArray *components = [message componentsSeparatedByString:@"::"];
    NSString *command = [[components firstObject] description];
    BOOL didHandleMessage = NO;
    NSString *commandId = @"";

    didHandleMessage = [self onCommandFromWebPage: command withParams: [NSMutableDictionary dictionaryWithDictionary:@{@"components": components}] andCommandId: commandId];

    if (!didHandleMessage) {
        [BFSDKLogger logMessage:@"Unhandled butterfly message: %@", message];
        [self markAsHandled: command withResult: @""];
    }
}

- (BOOL) onCommandFromWebPage:(NSString *) command
                  withParams:(NSMutableDictionary *) params
                andCommandId:(NSString *) commandId {
    BOOL didHandleMessage = NO;

    if ([command isEqualToString:@"cancel"]) {
        [self dismissViewControllerAnimated:YES completion:nil];

        didHandleMessage = YES;
    } else if ([command isEqualToString:@"flutterIsReady"]) {
        didHandleMessage = YES;
    } else if ([command isEqualToString:@"open"]) {
        NSArray *components = params[@"components"];

        NSString *urlString = [[components lastObject] description];
        NSURL *url = [NSURL URLWithString: urlString];
        BOOL isValid = [url scheme] && [url host];
        if (isValid) {
            [[UIApplication sharedApplication] openURL: url];
        }

        didHandleMessage = YES;
        [self markAsHandled: commandId withResult: @"OK"];
    } else if ([command isEqualToString:@"backToPreviousScreen"]) {
        [self.navigationController popViewControllerAnimated: true];

        didHandleMessage = YES;
        [self markAsHandled: commandId withResult: @"OK"];
    } else if ([command isEqualToString:@"navigateTo"]) {
        NSString *urlString = params[@"urlString"];

        if ([urlString isKindOfClass: [NSString class]]) {
            BFBrowserViewController *browserViewController = [[BFBrowserViewController alloc] init];
            browserViewController.url = [NSURL URLWithString:urlString];
            [self.navigationController pushViewController:browserViewController animated:true];
        }

        didHandleMessage = YES;
        [self markAsHandled: commandId withResult: @"OK"];
    } else if ([command isEqualToString:@"allowNavigation"]) {
        NSString *urlString = params[@"urlString"];

        if ([urlString isKindOfClass:[NSString class]]) {
            [BFBrowserViewController.urlWhiteList addObject: urlString];
        }
        
        [self markAsHandled: commandId withResult: @"OK"];
        didHandleMessage = YES;
    } else if ([command isEqualToString:@"sendRequest"] && [params valueForKey:@"urlString"]) {
        NSString *urlString = [([params valueForKey:@"urlString"] ?: @"") description];
        NSString *apiKey = [([params valueForKey:@"key"] ?: @"") description];
        if (![ButterflyUtils isRunningReleaseVersion] && ![apiKey hasPrefix:@"debug-"]) {
            apiKey = [NSString stringWithFormat: @"debug-%@", apiKey];
        }

        [params removeObjectForKey:@"key"];
        [params removeObjectForKey:@"urlString"];

        didHandleMessage = YES;

        [ButterflyUtils sendRequest: [NSDictionary dictionaryWithDictionary: params] toUrl:urlString withHeaders:@{@"butterfly_host_api_key": apiKey} completionCallback:^(NSString *responseString) {
            [BFSDKLogger logMessage:responseString];

            if (![responseString isEqualToString: @"OK"]) {
                responseString = @"error";
            }
            
            [self markAsHandled: commandId withResult: responseString];
        }];
    } else {
        [BFSDKLogger logMessage: @"Unhandled butterfly command: %@", command];
    }
    
    return didHandleMessage;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *) message {
    BOOL didHandleMessage = NO;
    NSString *commandId = @"";
    if ([[message body] isKindOfClass: [NSDictionary class]]) {
        NSMutableDictionary *commandFromJs = [NSMutableDictionary dictionaryWithDictionary: [message body]];
        NSString *commandName = [[commandFromJs valueForKey:@"commandName"] description];
        NSString *_commandId = [([commandFromJs valueForKey:@"commandId"] ?: @"") description];

        if ([_commandId length]) {
            commandId = _commandId;
        }

        [commandFromJs removeObjectForKey:@"commandName"];
        [commandFromJs removeObjectForKey:@"commandId"];

        didHandleMessage = [self onCommandFromWebPage: commandName withParams: commandFromJs andCommandId: commandId];
    }
    
    if (!didHandleMessage) {
        [BFSDKLogger logMessage:@"Unhandled butterfly message: %@", message];
        [self markAsHandled: commandId withResult: @""];
    }
}

-(void) markAsHandled:(NSString *) commandId withResult: (NSString *) result {
    if (!commandId || [[commandId description] length] == 0) return;

    __weak __typeof__(self) weakSelf = self;

    NSString* jsCommand = [NSString stringWithFormat: @"bfPureJs.commandResults['%@'] = '%@';", commandId, result];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong __typeof__(self) strongSelf = weakSelf;
        [[strongSelf webView] evaluateJavaScript: jsCommand completionHandler:^(id _Nullable jsResult, NSError * _Nullable error) {
            if (error) {
                [BFSDKLogger logMessage: [error description]];
            }
        }];
    }];
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

+ (void)launchUrl:(NSString *)url result:(BFBrowserResult)result {
    [[[BFBrowser alloc] init] launchUrlInViewController: url result:result];
}

- (void)launchUrlInViewController:(NSString *) urlString result:(BFBrowserResult) result {
    NSURL *url = [NSURL URLWithString:urlString];
    BFBrowserViewController *browserViewController = [[BFBrowserViewController alloc] init];
    browserViewController.url = url;
    
    BFBrowserNavigationController *browserNavigationController = [[BFBrowserNavigationController alloc] initWithRootViewController: browserViewController];
    browserNavigationController.interactivePopGestureRecognizer.delegate = nil;
    browserNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [[ButterflyHostController topViewController] presentViewController: browserNavigationController
                                                              animated:YES
                                                            completion:^{
        if (result) {
            result(@"OK");
        }
    }];
}

@end
