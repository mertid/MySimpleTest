//
//  TEALWKConfiguration.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/3/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This is a lighter-weight version of the TEALConfiguration object meant
    specifically for use in a watchOS extension. Create an instance of this class
    to pass as an argument into a TEALWKExtension init method.
 */
@interface TEALWKExtensionConfiguration : NSObject

/**
 *  Tealium iQ account name
 */
@property (nonatomic, copy) NSString *accountName;

/**
 *  Tealium iQ profile name, this should be the TiQ profile where the mobile publish settings have been configured for Tealium collect.
 *
 *  Note: This is usually not the same profile used for Collect which defaults to "main"
 */
@property (nonatomic, copy) NSString *profileName;

/**
 *  Tealium iQ evnvironment name.
 *
 *  @example dev/qa/prod
 */
@property (nonatomic, copy) NSString *environmentName;

/**
 *  The instance id assigned to the library instance associated with this configuration.
 *
 *  @param instanceID NSString identifier
 */
@property (nonatomic) NSString *instanceID;

/**
 *  Creates a default configration instance for a given account / profile / environment combination.  The TiQ information is used to fetch the profile's mobile publish settings used
 *
 *  @param accountName     String of TiQ / AudienceStream account name
 *  @param profileName     String of TiQ Profile Name
 *  @param environmentName String
 *
 *  @return Valid configuration instance to pass to the enableWithConfiguration: method.
 */
+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName;

/**
 *  Checks to see if configuration is populated with the minimum required properties.
 *
 *  @param configuration TEALConfiguration to check.
 *
 *  @return Boolean of whether the argument configuration is valid.
 */
+ (BOOL) isValidConfiguration:(TEALWKExtensionConfiguration *)configuration;

@end
