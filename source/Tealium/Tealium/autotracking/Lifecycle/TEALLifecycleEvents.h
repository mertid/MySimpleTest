//
//  TEALLifecycleEvents.h
//  Tealium
//
//  Created by Jason Koo on 9/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALLifecycleEvents : NSObject <NSCoding, NSCopying, NSSecureCoding>

- (void) addEvent;

- (void) setEvents:(NSDictionary *)newEvents;

- (double) currentCount;

- (double) totalCount;

- (NSDictionary *) allEvents;

- (NSDate *) firstEvent;

- (NSDate *) lastEvent;

- (NSDate *) lastUpdate;

- (NSDictionary *) dataForUserDefaults;

- (void) loadFromUserDefaults:(NSDictionary *)dictionary;

@end
