//
//  TEALS2SLegacyDispatchManager.h
//  Tealium Mobile Library
//
//  Created by Jason Koo on 10/29/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: This uses the original i.gif POST call

#import <Foundation/Foundation.h>
#import "TEALSystemProtocols.h"
#import "TEALDispatchService.h"

@class TEALURLSessionManager;


@interface TEALS2SLegacyDispatchService : NSObject <TEALDispatchService>

- (instancetype _Nullable) initWithDispatchURLString:(NSString * _Nonnull)dispatchURLString
                                           visitorID:(NSString * _Nonnull)visitorID
                                      sessionManager:(TEALURLSessionManager * _Nonnull)sessionManager;

- (NSString * _Nullable) dispatchURLStringCopy;

- (NSURLRequest * _Nullable) requestForDispatch:(TEALDispatch * _Nonnull) dispatch
                                error:(NSError * _Nullable * _Nullable)error;
@end
