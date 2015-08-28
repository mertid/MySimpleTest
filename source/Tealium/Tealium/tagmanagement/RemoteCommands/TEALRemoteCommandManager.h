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

@class TEALOperationManager;

@protocol TEALRemoteCommandDelegate <NSObject>

- (void) tagRemoteCommandRequestsCommandToWebView:(NSString *)command;

@end

@interface TEALRemoteCommandManager : NSObject <TEALRemoteCommandResponseDelegate>

@property (nonatomic, weak) id<TEALRemoteCommandDelegate> delegate;

- (instancetype) initWithOperationManager:(TEALOperationManager*)manager;

- (void) addReservedCommands;

- (void) processRequest:(NSURLRequest*)request completionHandler:(TEALRemoteCommandResponseBlock)responseBlock;

- (void) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock;

@end
