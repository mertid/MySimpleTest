//
//  TEALDataStore.h
//  Tealium
//
//  Created by Jason Koo on 9/28/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//


#import <Foundation/Foundation.h>


/**
 *  Private data storage handling base class. Implements subscripting so mutable
 *  dictionary literal type subscript commands can be used on instances of this
 *  class or it's subclasses
 */
@interface TEALDataStore : NSObject

@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) NSMutableDictionary *data;
@property (nonatomic, readonly) NSString *instanceID;
@property (nonatomic, readonly) NSString *storageKey;

- (instancetype) initWithInstanceID:(NSString *) instanceID;

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key;
- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (void) addEntriesFromDictionary:(NSDictionary *)dictionary;

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey;


- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (void) removeObjectForKey:(id<NSCopying, NSSecureCoding>)key;

@end
