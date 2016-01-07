//
//  TEALRemoteCommand.h
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALRemoteCommandResponse.h"

@interface TEALRemoteCommand : NSObject

@property (nonatomic, strong) NSString *commandID;
@property (nonatomic, strong) NSString *commandDescription;
@property (nonatomic, weak) dispatch_queue_t queue;
@property (nonatomic, copy) TEALRemoteCommandResponseBlock responseBlock;

@end
