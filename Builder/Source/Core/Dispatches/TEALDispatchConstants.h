//
//  TEALDispatchConstants.h
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

@class TEALDispatch;

typedef NS_ENUM(NSUInteger, TEALDispatchStatus) {
    TEALDispatchStatusUnknown = 0,
    TEALDispatchStatusSent,
    TEALDispatchStatusQueued,
    TEALDispatchStatusDestroyed,
    TEALDispatchStatusFailed
};

typedef void (^TEALDispatchBlock)(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error);

