//
//  TEALDelegateManager.h
//  Tealium
//
//  Created by Jason Koo on 7/22/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TealiumDelegate.h"

@interface TEALDelegateManager : NSObject <TealiumDelegate>

- (void) updateWithDelegate:(id<TealiumDelegate>)delegate;
- (id<TealiumDelegate>) delegate;

@end
