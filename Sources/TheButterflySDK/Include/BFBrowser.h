// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "ButterflyUtils.h"

typedef void (^BFBrowserResult)(id _Nullable result);

@interface BFBrowser: NSObject

+(void)launchUrl:(NSString *_Nullable)url
          result:(BFBrowserResult _Nullable )result;

+ (void)fetchButterflyParamsFromURL:(NSMutableDictionary<NSString *, NSString *> *_Nullable)urlParams
                             appKey:(NSString * _Nonnull)appKey
                         sdkVersion:(NSString * _Nonnull)sdkVersion
                         completion:(void (^_Nonnull)(NSDictionary * _Nullable butterflyParams))completion;

@end
