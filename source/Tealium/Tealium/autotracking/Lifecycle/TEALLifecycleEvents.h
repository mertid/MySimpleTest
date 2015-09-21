//
//  TEALLifecycleEvents.h
//  Tealium
//
//  Created by Jason Koo on 9/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALLifecycleEvents : NSObject

- (void) incrementCountNow;
- (void) startNewCountNow;
- (NSDate *) lastEventDate;
- (NSDate *) lastNewCountRecorded;
- (NSNumber *) currentCount;
- (NSNumber *) totalCount;

@end
