//
//  Tealium+Debug.m
//  FrameworkBuilder
//
//  Created by Jason Koo on 9/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import "Tealium+Debug.h"
#import "Tealium+PrivateHeader.h"
#import "TEALConfiguration+Debug.h"
#import "TEALSettings+Debug.h"
#import "TEALDebugServer.h"

@implementation Tealium (Debug)

- (void) updateDebug {
    
    // Check settings to enable/disable debugging
    if ([self.settings debugEnabled]) {
        
        // TODO: enable
        TEALDebugServer *server = [[TEALDebugServer alloc] init];
        [server startServer];
        
    } else {
        
        // TODO: disable
    }
    
}




@end
