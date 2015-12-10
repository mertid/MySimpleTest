//
//  TEALWKConfiguration.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/3/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TEALWKLogLevel){
    /**
     *  Nothing is logged to the console, this is the default.
     */
    TEALWKLogLevelNone = 0,
    /**
     *  Only errors reported.
     */
    TEALWKLogLevelProd,
    /**
     *  Provides warnings and errors only.
     */
    TEALWKLogLevelQA,
    /**
     *  Most verbose - Useful for debugging and verification during development.
     */
    TEALWKLogLevelDev
    
};

/**
 *  This is a lighter-weight version of the TEALConfiguration object meant
    specifically for use in a watchOS extension. Create an instance of this class
    to pass as an argument into a TEALWKExtension init method.
 */
@interface TEALWKExtensionConfiguration : NSObject

/**
 *  The number of track events to store when the host iOS device in not reachable.
 *
 *  Default - 100
 */
@property (nonatomic) NSUInteger offlineDispatchQueueSize;

/**
 *  Level of console log output to produce.
 *
 *  Default - TEALWKLogLevelNone
 */
@property (nonatomic) TEALWKLogLevel logLevel;

/**
 *  Creates a default configration instance for a given account / profile / environment combination.  The TiQ information is used to fetch the profile's mobile publish settings used
 *
 *  @return Valid configuration instance to pass to the enableWithConfiguration: method.
 */
+ (instancetype) configuration;

@end
