//
//  TEALVisitorProfileStore.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/18/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALBlocks.h"
#import "TEALVisitorProfileHelpers.h"
#import "TEALVisitorProfileDelegate.h"
#import "TEALSystemProtocols.h"


@interface TEALVisitorProfileStore : NSObject

@property (readonly, nonatomic) TEALVisitorProfile *currentProfile;
@property (weak, nonatomic) id<TEALVisitorProfileDelegate> profileDelegate;


- (instancetype) initWithVisitorID:(NSString *)visitorID profileURL:(NSURL *)profileURL profileDefinitionURL:(NSURL *)profileDefinitionURL urlSessionManager:(TEALURLSessionManager *)sessionManager;

- (void) fetchProfileWithCompletion:(TEALVisitorProfileCompletionBlock)completion;

- (void) fetchProfileDefinitionsWithCompletion:(TEALDictionaryCompletionBlock)completion;



@end
