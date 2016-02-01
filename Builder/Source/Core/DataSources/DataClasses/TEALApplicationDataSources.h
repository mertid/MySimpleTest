//
//  TEALApplicationDataSources.h
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALApplicationDataSources : NSObject

+ (NSDictionary *) dataSources;

+ (NSString *) appVersion;

@end
