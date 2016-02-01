//
//  TEALRemoteCommandErrors.h
//  Tealium
//
//  Created by Jason Koo on 8/26/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALRemoteCommandConstants.h"
#import "TEALRemoteCommandResponse.h"

@interface TEALRemoteCommandErrors : NSObject

+ (void) returnError:(TEALRemoteResponseErrors)errorType response:(TEALRemoteCommandResponse*)response identifier:(NSString*)identifier responseBlock:(TEALRemoteCommandResponseBlock)responseBlock;


@end
