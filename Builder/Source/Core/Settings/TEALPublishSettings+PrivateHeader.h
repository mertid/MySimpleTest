//
//  TEALPublishSettings+PrivateHeader.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#ifndef TEALPublishSettings_PrivateHeader_h
#define TEALPublishSettings_PrivateHeader_h

#import "TEALPublishSettings.h"

@interface TEALPublishSettings (Private)

@property (nonatomic) NSMutableDictionary *privatePublishSettingsData;

- (NSMutableDictionary *) moduleData;

- (id) moduleObjectForKey:(id<NSCopying, NSSecureCoding>)key;

- (void) setModuleObject:(id<NSCopying, NSSecureCoding>)object
                  forKey:(id<NSCopying, NSSecureCoding>)aKey;


@end


#endif /* TEALPublishSettings_PrivateHeader_h */
