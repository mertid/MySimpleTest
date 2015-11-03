//
//  TEALModulesDelegate.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  Brief: All optional commands to enable/disable modules listed here

#ifndef Tealium_TEALModulesDelegate_h
#define Tealium_TEALModulesDelegate_h

@protocol TEALModulesDelegate <NSObject>

@optional

- (void) enableCollect;
- (void) enableCollectLegacy;
- (void) enableTagManagement;
- (void) enableAutotrackingCrashes;
- (void) enableAutotrackingLifecycle;
- (void) enableAutotrackingUIEvents;
- (void) enableAutotrackingViews;
- (void) enableMobileCompanion;
- (void) enableRemoteCommands;

- (void) disableCollect;
- (void) disableCollectLegacy;
- (void) disableTagMangement;
- (void) disableAutotrackingLifecycle;
- (void) disableAutotrackingCrashes;
- (void) disableAutotrackingUIEvents;
- (void) disableAutotrackingViews;
- (void) disableMobileCompanion;
- (void) disableRemoteCommands;

- (void) revealMobileCompanion;


@end

#endif
