//
//  TEALSettings+Debug.m
//  FrameworkBuilder
//
//  Created by Jason Koo on 9/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import "TEALSettings+Debug.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALConfiguration+Debug.h"

@implementation TEALSettings (Debug)

- (BOOL) debugEnabled {
    
    return [[self configuration] isDebugEnabled];
    
}

@end
