//
//  TEALDataSources+Private.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALDataSourceStore;

@interface TEALDataSources_Private : NSObject

@property (nonatomic, strong) NSMutableDictionary *datasources;
//@property (nonatomic, strong) TEALDataSourceStore *store;

- (id) instanceStore;

@end
