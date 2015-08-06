//
//  TEALDispatchConstants.h
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#warning Check to see if we should include these with TEALDispatch

@class TEALDispatch;

typedef NS_ENUM(NSUInteger, TEALDispatchStatus) {
    TEALDispatchStatusUnknown = 0,
    TEALDispatchStatusSent,
    TEALDispatchStatusQueued,
    TEALDispatchStatusShouldDestory,
    TEALDispatchStatusFailed
};

typedef void (^TEALDispatchBlock)(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error);

