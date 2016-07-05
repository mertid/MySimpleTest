//
//  TEALRemoteCommandResponse.m
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALRemoteCommandResponse+PrivateHeader.h"
#import "TEALRemoteCommandErrors.h"
#import "TEALRemoteCommandConstants+PrivateHeader.h"
#import "TEALError.h"

@implementation TEALRemoteCommandResponse

- (NSString*) description{
    return [NSString stringWithFormat:@"<%@: %p, Command Id: %@ Response Id: %@ Status: %li Body: %@ Payload:%@ Error:%@>",
            NSStringFromClass([self class]), self, self.commandId, self.responseId, (long)self.status, self.body, self.requestPayload ,self.error];
    
}

- (void) send{
    if (self.delegate){
        [self.delegate tealiumRemoteCommandResponseRequestsSend:self];
    }
}


@end
