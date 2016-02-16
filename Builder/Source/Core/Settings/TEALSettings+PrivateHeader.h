//
//  TEALSettings+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 9/19/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALSettings.h"
#import "TEALConfiguration.h"
#import "TEALPublishSettings.h"
#import "TEALBlocks.h"

@interface TEALSettings (Private)

@property (nonatomic, strong) TEALConfiguration *configuration;
@property (nonatomic, strong) TEALPublishSettings *privatePublishSettings;
@property (nonatomic, strong) NSDate *lastFetch;

- (BOOL) autotrackingApplicationInfoEnabled;
- (BOOL) autotrackingCarrierInfoEnabled;
- (BOOL) autotrackingTimestampInfoEnabled;

- (double) minutesBeforeNextFetchFromDate:(NSDate *)date
                                  timeout:(double)timeout;

@end