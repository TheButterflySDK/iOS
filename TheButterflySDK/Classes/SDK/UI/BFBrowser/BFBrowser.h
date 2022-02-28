// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

typedef void (^BFBrowserResult)(id _Nullable result);

@interface BFBrowser: NSObject

+(void)launchURLInViewController:(NSString *_Nullable) url result:(BFBrowserResult _Nullable ) result;

@end
