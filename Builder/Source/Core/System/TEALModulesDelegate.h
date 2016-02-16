//
//  TEALModulesDelegate.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  Brief: All optional commands to enable/disable modules listed here

@protocol TEALModulesDelegate <NSObject>

@optional

- (void) updateCollect;
- (void) updateS2SLegacy;
- (void) updateTagManagement;

//- (void) enableCollect;
//- (void) enableS2SLegacy;
- (void) enableTagManagement;
- (void) enableAutotrackingCrashes;
- (void) enableAutotrackingLifecycle;
- (void) enableAutotrackingUIEvents;
- (void) enableAutotrackingViews;
- (void) enableMobileCompanion;
- (void) enableRemoteCommands;

- (void) disableCollect;
- (void) disableS2SLegacy;
- (void) disableTagMangement;
- (void) disableAutotrackingLifecycle;
- (void) disableAutotrackingCrashes;
- (void) disableAutotrackingUIEvents;
- (void) disableAutotrackingViews;
- (void) disableMobileCompanion;
- (void) disableRemoteCommands;

- (void) updateWatchKitPublishSettings;
- (void) revealMobileCompanion;
- (void) fetchVisitorProfileAfterEvent;


@end