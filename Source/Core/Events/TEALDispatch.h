//
//  TEALDispatch.h
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Types of available dispatches
 */
typedef NS_ENUM(NSUInteger, TEALDispatchType) {
    /**
     *  A dispatch with an unassigned type.
     */
    TEALDispatchTypeNone,
    /**
     *  Any non-view type dispatch.
     */
    TEALDispatchTypeEvent,
    /**
     *  Dispatch for view / screen appearances only.
     */
    TEALDispatchTypeView
};

/**
 *  Constants for the two most common dispatch types
 *
 */
extern NSString * const TEALDispatchTypeLinkStringValue; // string actual - "link"
extern NSString * const TEALDispatchTypeViewStringValue; // string actual - "view"

@interface TEALDispatch : NSObject <NSCoding>

/**
 *  Type of dispatch, either 'link' or 'view'
 */
@property (nonatomic) TEALDispatchType dispatchType;

/**
 *  Name of the dispatch service used to deliver track call.
 *
 */
@property (nonatomic, strong) NSString *dispatchServiceName;

/**
 *  The populated datasources available for mapping with the dispatch.
 */
@property (nonatomic, strong) NSDictionary *payload;

/**
 *  Time in Unix epoch of when the dispatch origin track call was called. 
 */
@property (nonatomic) NSTimeInterval timestamp;



@end
