//
//  TEALDatasourceStore.h
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Handles persistent datasources

#import <Foundation/Foundation.h>

@interface TEALDataSourceStore : NSObject

- (instancetype) initWithInstanceID:(NSString *) instanceID;

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key;

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey;

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (NSDictionary *) dataSourcesCopy;

- (void) addDataSources:(NSDictionary *)additionalDataSources;

- (void) removeDataSourceForKey:(NSString *)dataSourceKey;

- (void) removeAllDataSources;

@end
