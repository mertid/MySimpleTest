//
//  Tealium+TagManagement.h
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef TEAL_MODULE_TAGMANAGEMENT
#define TEAL_MODULE_TAGMANAGEMENT
#endif

#import "Tealium.h"

#import "TEALRemoteCommandResponse.h"

@interface Tealium (TagManagement)

- (void) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock;

@end
