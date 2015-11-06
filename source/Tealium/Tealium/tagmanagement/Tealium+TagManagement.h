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

/*
 *  Adds a remote command block that can be triggered by the instance's TIQ templates.
 *
 *  @param name NSString that identifies this code block
 *  @param description Optional NSString description of the command block
 *  @param targetQueue The dispatch queue to run the command on.  Note, any UI commands must be done on the main thread.
 *  @param responseBlock An optional block that returns a TEALRemoteCommandResponse object whenever the command is executed.
 */
- (void) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock;

@end
