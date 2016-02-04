//
//  TEALRemoteCommands.h
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALRemoteCommandResponse+PrivateHeader.h"
#import "TEALRemoteCommandConstants.h"
#import "TEALBlocks.h"

@class TEALOperationManager;

@protocol TEALRemoteCommandManagerDelegate <NSObject>

- (void) tagRemoteCommandManagerRequestsCommandToWebView:(NSString *)command;

@end

@interface TEALRemoteCommandManager : NSObject <TEALRemoteCommandResponseDelegate>

@property (nonatomic, weak) id<TEALRemoteCommandManagerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *commands;


+ (NSString *) commandStringFromURLString:(NSString *)urlString
                                    error:(NSError * __autoreleasing)error;

+ (NSString *) commandIDFromCommandString:(NSString *)commandString;

- (instancetype) initWithOperationManager:(TEALOperationManager*)manager;

- (void) addReservedCommands:(TEALBooleanBlock)successBlock;

- (void) removeAllCommands;
/**
 *  Called by webview if Tag Bridge formatted url request string found.
 *
 *  @param commandString NSString of url string with tealium:// prefix removed.
 *  @param responseBlock This is the block that will be called if the command is executed.
 *  @param completion Completion block that reports if the remote command block was added.
 */
- (void) processCommandString:(NSString *)commandString
                responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                   completion:(TEALBooleanCompletionBlock)completion;

- (void) addRemoteCommandID:(NSString*)name
                description:(NSString*)description
                targetQueue:(dispatch_queue_t)queue
              responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                 completion:(TEALBooleanCompletionBlock)completion;

- (void) removeRemoteCommandID:(NSString *)name
                    completion:(TEALBooleanCompletionBlock)completion;

@end
