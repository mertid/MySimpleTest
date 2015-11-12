//
//  TEALDataSources+Private.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALDataSourceStore;

@interface TEALDataSources (Private)

@property (nonatomic, strong) NSMutableDictionary *datasources;

- (id) instanceStore;

@end
