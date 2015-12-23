//
//  TEALConfiguration.h
//  Tealium Mobile Library
//
//  Created by George Webster on 3/2/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Configuration Types

/**
 *  Unsigned integer value that controls the frequency at which the user's visitor profile is requested from AudienceStream
 */
typedef NS_ENUM(NSUInteger, TEALVisitorProfilePollingFrequency){
    /**
     *  On request only, will only poll AudienceStream with the fetchVisitorProfileWithCompletion: method
     */
    TEALVisitorProfilePollingFrequencyOnRequest = 1,
    /**
     *  After each event (sendEventWithData: or sendViewWithData:) an updated visitor profile will be requested.
     */
    TEALVisitorProfilePollingFrequencyAfterEveryEvent
};


/**
 *  Configuration Class for the Tealium Mobile Library
 *  An instance of this is passed to Tealium enableWithConfiguration: to start the Collect Library
 */
@interface TEALConfiguration : NSObject

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
 *  Flag for allowing remote commands triggerable via the Tag Management dispatch service.
 *
 *  @default YES
 */
@property (nonatomic) BOOL remoteCommandsEnabled;

/**
 *  Flag when on will send all data for HTTP.  Suggested to be used in development only!
 *
 *  @default NO
 */
@property (nonatomic) BOOL useHTTP;

/**
 *  Frequency at which visitor profile should be polled.  
 *  By default after each sendEventWithData: and sendViewWithData: call an updated visitor profile will be requested.
 *  If set to on request, the library will only requery the profile when asked for using fetchVisitorProfileWithCompletion:
 *
 *  @default TEALVisitorProfilePollingFrequencyAfterEveryEvent
 *  @see TEALVisitorProfilePollingFrequency
 */
@property (nonatomic) TEALVisitorProfilePollingFrequency pollingFrequency;

/**
 *  If assigned, will replace the default mobile publish setting source location with an alternate address. Example - "https://my.domain.com/app/publish.html"
 */
@property (nonatomic) NSString *overridePublishSettingsURL;

/**
 *  If assigned, will replace the default address used to retrieve the tag management UTAG.js file.  Example - "https://my.domain.com/app/mobile.html"
 */
@property (nonatomic) NSString *overridePublishURL;

/**
 *  If assigned, will replace the destination endpoint for Collect dispatch calls.
 */
@property (nonatomic) NSString *overrideCollectDispatchURL;

/**
 *  If assigned, will replace the destination endpoint for S2S Legacy dispatch calls.
 */
@property (nonatomic) NSString *overrideS2SLegacyDispatchURL;

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
+ (BOOL) isValidConfiguration:(TEALConfiguration *)configuration;

@end
