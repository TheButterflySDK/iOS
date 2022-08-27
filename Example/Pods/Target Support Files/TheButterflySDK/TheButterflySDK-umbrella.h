#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ButterflyHostController.h"
#import "ButterflySDK.h"
#import "TheButterflySDK.h"
#import "BFBrowser.h"
#import "BFToastMessage.h"
#import "BFUserInputHelper.h"
#import "ButterflyUtils.h"
#import "DeviceInfoGetter.h"
#import "TheButterflySDK-Bridging-Header.h"

FOUNDATION_EXPORT double TheButterflySDKVersionNumber;
FOUNDATION_EXPORT const unsigned char TheButterflySDKVersionString[];

