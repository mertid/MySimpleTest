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

#warning MERGE with TEALError codes?

typedef NS_ENUM(NSInteger, TealiumResponseCodes){
    TealiumRC_Unknown   = 0,
    TealiumRC_Success   = 200,
    TealiumRC_NoContent = 204,
    TealiumRC_Malformed = 400,
    TealiumRC_Failure   = 404,  // command not found
    TealiumRC_Exception = 555
};
