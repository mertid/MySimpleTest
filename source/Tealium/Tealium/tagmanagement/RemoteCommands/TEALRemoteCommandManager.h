//
//  TEALRemoteCommands.h
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALRemoteCommandResponse.h"
#import "TEALRemoteCommandConstants.h"
#import "TEALBlocks.h"

@class TEALOperationManager;

@protocol TEALRemoteCommandManagerDelegate <NSObject>

- (void) tagRemoteCommandManagerRequestsCommandToWebView:(NSString *)command;

@end

@interface TEALRemoteCommandManager : NSObject <TEALRemoteCommandResponseDelegate>

@property (nonatomic, weak) id<TEALRemoteCommandManagerDelegate> delegate;

- (instancetype) initWithOperationManager:(TEALOperationManager*)manager;

- (void) addReservedCommands:(TEALBooleanBlock)successBlock;

- (void) processRequest:(NSURLRequest*)request completionHandler:(TEALRemoteCommandResponseBlock)responseBlock;

- (BOOL) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock;

@end
