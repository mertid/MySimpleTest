//
//  UIWebView+Tealium.h
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Tealium)

- (BOOL) teal_areRemoteCommandsEnabled;

- (void) teal_setAreRemoteCommandsEnabled:(BOOL) enable;

@end
