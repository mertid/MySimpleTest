//
//  TEALBlocks+TagManagement.h
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

typedef NS_ENUM(NSUInteger, TEALRemoteResponseErrors) {
    TEALRemoteResponseErrorUnknown,
    TEALRemoteResponseErrorMalformedURL,
    TEALRemoteResponseErrorMissingArgs,
    TEALRemoteResponseErrorMissingCommand,
    TEALRemoteResponseErrorMissingCommandId,
    TEALRemoteResponseErrorMissingCommandBlock,
    TEALRemoteResponseErrorMissingRequest,
    TEALRemoteResponseErrorHttp_NoMethodType,
    TEALRemoteResponseErrorHttp_NoTargetUrl
};
