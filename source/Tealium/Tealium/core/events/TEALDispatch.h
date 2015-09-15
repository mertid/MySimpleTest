//
//  TEALDispatch.h
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TEALDispatchType) {
    TEALDispatchTypeNone,
    TEALDispatchTypeEvent,
    TEALDispatchTypeView
};

extern NSString * const TEALDispatchTypeLinkStringValue;
extern NSString * const TEALDispatchTypeViewStringValue;

@interface TEALDispatch : NSObject <NSCoding>

@property (nonatomic) TEALDispatchType dispatchType;
@property (nonatomic, strong) NSString *dispatchServiceName;
@property (nonatomic, strong) NSDictionary *payload;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) BOOL queued;

+ (TEALDispatch *) dispatchForType:(TEALDispatchType)dispatchType withPayload:(NSDictionary *)payload;
+ (NSString *) stringFromDispatchType:(TEALDispatchType)dispatchType;


@end
