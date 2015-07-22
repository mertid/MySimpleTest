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

@property (readonly, nonatomic) id<TealiumDelegate> delegate;

- (void) updateWithDelegate:(id<TealiumDelegate>)delegate;

@end
