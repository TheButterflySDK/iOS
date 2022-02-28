//
//  ButterflyHostController.h
//  butterfly
//
//  Created by Aviel on 11/17/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ButterflyHostController: NSObject

+(void) openReporterWithKey:(NSString*)key;

+ (UIViewController *)topViewController;

@end
