//
//  TEALModulesDelegate.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef Tealium_TEALModulesDelegate_h
#define Tealium_TEALModulesDelegate_h

@protocol TEALModulesDelegate <NSObject>

@optional

- (void) enableAudienceStream;
- (void) enableTagManagement;

- (void) enableAutotrackingIvars;
- (void) enableAutotrackingLifecycle;
- (void) enableAutotrackingUIEvents;
- (void) enableAutotrackingViews;

- (void) enableRemoteCommands;

@end

#endif
