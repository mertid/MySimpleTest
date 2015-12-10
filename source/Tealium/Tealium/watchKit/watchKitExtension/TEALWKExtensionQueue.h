//
//  TEALWKExtensionQueue.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/9/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALWKExtensionQueue : NSObject

/**
 *  Save the entire call dictionary for later delivery.
 *
 *  @param payload NSDictionary of entire track call metadata to be passed to
 *  the TEALWKDelegate class which will convert the payload into a full Tealium
 *  track call.
 */
- (void) queueCallPayload:(NSDictionary *)payload;

/**
 *  Returns a copy of the internal queue array of all track data waiting to be
 *  processed.
 *
 *  @return An array of all queued track data.
 */
- (NSArray *) currentQueue;

/**
 *  Removes the oldest call in queue.
 */
- (void) removeFirstCall;

/**
 *  Resets the internal queue.
 */
- (void) purgeQueue;

@end
