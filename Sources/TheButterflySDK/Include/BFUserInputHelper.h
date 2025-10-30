//
//  BFUserInputHelper.h
//  butterfly
//
//  Created by Aviel on 10/9/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BFUserInputHelper: NSObject

-(void) getUserInput:(UIViewController*)viewController onDone:(void (^)(NSString * wayContact, NSString* fakePlace , NSString* comments))completion ;

@property (nonatomic,strong) UIAlertController* alertController;

@end
