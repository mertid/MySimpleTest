//
//  TEALMobileCompanion.h
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TEALMobileCompanionDelegate.h"

@interface TEALMobileCompanion : UIViewController

@property (nonatomic, weak) id<TEALMobileCompanionDelegate> delegate;

- (instancetype) initWithInstanceID:(NSString *)instanceID;

- (void) reveal;

@end
