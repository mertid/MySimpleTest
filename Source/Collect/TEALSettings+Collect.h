//
//  TEALSettings+Collect.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALSettings.h"

@interface TEALSettings (Collect)

/**
 *  Is the collect module enabled by publish settings.
 *
 *  @return BOOL Where yes equals to enabled.
 */
- (BOOL) collectEnabled;

/**
 *  Is the s2s legacy system enabled by publish settings.
 *
 *  @return BOOL Where yes equals to enabled.
 *
 */
- (BOOL) s2SLegacyEnabled;

/**
 *  How often should the collect system check for udpated visitor data.
 *
 *  @return NSUInteger Integer representation of the TEALVisitorProfilePollingFrequency enum.
 */
- (NSUInteger) collectPollingFrequency;

/**
 *  Trace id currently active - if set. Calls current Configurations traceID.
 */
- (NSString * _Nullable) traceID;

/**
 *  Current destination URL endpoint for collect dispatches.
 *
 *  @param visitorID associated with the target collect service
 *
 *  @return NSString String representation of the target URL.
 */
- (NSString * _Nullable) collectDispatchURLStringForVisitorID:(NSString * _Nonnull)visitorID;

/**
 *  Current destination URL endpoint for s2s legacy dispatches.
 *
 *  @return NSString String representation of the target URL.
 */
- (NSString * _Nullable) s2SLegacyDispatchURLString;

/**
 *  The url used to retrieve the collect profile for AudienceStream, if service is running.
 */
- (NSURL * _Nullable) collectProfileURLForVisitorID:(NSString * _Nonnull)visitorID;

/**
 *  The url used to retrieve the collect profile definitions for AudienceStream, if service is running.
 */
- (NSURL * _Nullable) collectProfileDefinitionsURL;

/**
 *  Set current trace id.  Calls current Configurations setTraceID.
 *
 *  @param traceID String identifier of trace to use.
 */
- (void) setTraceID:(NSString * _Nonnull)traceID;

@end