//
//  TEALLifecycleStore.h
//  Tealium
//
//  Created by Jason Koo on 8/22/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALBlocks.h"

@interface TEALLifecycleStore : NSObject

- (instancetype) initWithInstanceID:(NSString *) instanceID;

- (void) loadAllData;

- (void) saveData:(NSDictionary *)data forKey:(NSString *)key completion:(TEALBooleanCompletionBlock)completion;

#warning DELETE BELOW

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key;

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey;

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

@end
