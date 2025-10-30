//
//  ToastMessage.m
//  butterfly
//
//  Created by Aviel on 11/11/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "BFToastMessage.h"

@interface BFToastMessage()

@property (nonatomic, strong) UILabel * _Nonnull messageLabel;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) BFToastCallback _Nullable callback;

@end

@implementation BFToastMessage

-(void) removeSelf {
    [UIView animateWithDuration: 0.5 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.8, 1);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.callback) {
            self.callback();
        }
    }];
}

+(void) show: (NSString *) messageText delayInSeconds:(NSTimeInterval) delay onDone:(void (^)(void)) callback {
    
    if (!NSThread.isMainThread) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [BFToastMessage show: messageText delayInSeconds: delay onDone: callback];
        }];
        
        return;
    }
    
    UIWindow *appWindow = UIApplication.sharedApplication.keyWindow;
    if (!appWindow) {
        if (callback) {
            callback();
        }
        
        return;
    }
    
    // Personally we sould prefer to use autolayout (constraints) but we rather not too, because we never can predeict wich kind of project will run this SDK, and the results are satisfying FOR DEBUG PURPOSES.
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    BFToastMessage *toastMessage = [[BFToastMessage alloc] initWithFrame: (CGRectMake(width * 0.1, height * 0.8	, width * 0.8, height * 0.1))];
    toastMessage.delay = delay;
    toastMessage.messageLabel = [[UILabel alloc] initWithFrame: (CGRectMake(width * 0.15, 0, width * 0.5, height * 0.1))];
    toastMessage.messageLabel.textAlignment = NSTextAlignmentCenter;
    toastMessage.messageLabel.text = messageText;
    toastMessage.messageLabel.textColor = [UIColor whiteColor];
    toastMessage.messageLabel.numberOfLines = 0;
    toastMessage.layer.cornerRadius = 30;
    toastMessage.layer.masksToBounds = YES;
    
    [toastMessage addSubview: toastMessage.messageLabel];
    toastMessage.userInteractionEnabled = NO;
    toastMessage.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent: 0.8];
    
    toastMessage.callback = callback;
    
    toastMessage.alpha = 0;
    [appWindow addSubview: toastMessage];
    toastMessage.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration: 0.3 animations:^{
        toastMessage.alpha = 1;
        toastMessage.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toastMessage removeSelf];
    });
}

@end
