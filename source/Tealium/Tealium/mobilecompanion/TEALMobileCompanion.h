//
//  TEALMobileCompanion.h
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TEALMobileCompanionDelegate.h"

@class TEALMobileCompanionContent;

@interface TEALMobileCompanion : UIViewController

@property (nonatomic, weak) id<TEALMobileCompanionDelegate> delegate;

- (instancetype) initWithInstanceID:(NSString *)instanceID;

- (void) addContent:(TEALMobileCompanionContent * )content forTitle:(NSString *)title;

- (void) enable;

- (void) disable;

- (BOOL) isEnabled;

- (void) refresh;

- (void) reveal;

- (void) forceDismiss;

@end
