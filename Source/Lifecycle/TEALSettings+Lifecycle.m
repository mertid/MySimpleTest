//
//  TEALSettings+TagManagement.m
//
//  Created by Jason Koo on 7/18/16.
//
//

#import "TEALSettings+Lifecycle.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALConfiguration+Lifecycle.h"

@implementation TEALSettings (Lifecycle)

- (BOOL) autotrackingLifecycleEnabled {
    
    return [[self configuration] isAutotrackingLifecycleEnabled];

}

@end
