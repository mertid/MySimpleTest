//
//  TEALSettingsTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TEALConfiguration+PrivateHeader.h"
#import "TEALPublishSettings+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALPublishSettingsConstants.h"
#import "TEALURLSessionManager.h"

#import "TEALTestHelper.h"

@interface TEALSettingsTests : XCTestCase

@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, strong) TEALConfiguration *configuration;

@end

@implementation TEALSettingsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.settings = nil;
    self.configuration = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - CONFIGURATIONS


- (void) testDefaultPublishSettingsURL {

    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                              profile:@"demo"
                                                          environment:@"dev"];

    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];

    NSString *publishURLString = [self.settings publishSettingsURLString] ;
    NSString *defaultURLString = @"https://tags.tiqcdn.com/utag/tealiummobile/demo/dev/mobile.html?";

    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
    
    XCTAssertTrue([publishURLString isEqualToString:defaultURLString], @"Default publish settings URL %@ did not equal default string expected:%@", publishURLString, defaultURLString);
}


- (void) testOverridePublishSettingsURLString {
    
    NSString *overrideURL = @"https://www.google.com";
    
    self.configuration = [TEALTestHelper configWithOverridePublishSetting:overrideURL];
    
    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
    
    NSString * publishSettingsURLString = [self.settings publishSettingsURLString];
    
    XCTAssertTrue([publishSettingsURLString isEqualToString:overrideURL], @"Override url %@ did not set settings publishSettingsURLString:%@.", overrideURL, publishSettingsURLString);
    
}

- (void) testOverridePublishSettingsURLForJSONSource {
    
    self.configuration = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    [self fetchNewSettingsWithConfig:self.configuration];
    
    NSDictionary *manualCopy = @{
                                 @"5": @{
                                         @"_is_enabled":@"true",
                                         @"battery_saver":@"true",
                                         @"dispatch_expiration":@"-1",
                                         @"enable_collect":@"true",
                                         @"enable_s2s_legacy":@"false",
                                         @"enable_tag_management":@"false",
                                         @"event_batch_size":@"1",
                                         @"minutes_between_refresh":@"0.0",
                                         @"offline_dispatch_limit":@"100",
                                         @"override_log":@"",
                                         @"wifi_only_sending":@"false"
                                         },
                                 @"_firstPublish":@"true"
                                 };
    
    NSDictionary *five = manualCopy[@"5"];
    
    // Do not do dictionary comparison from JSON sources as the JSON parser converst some of the string to numbers / booleans
    
//    NSDictionary *publishSettings = self.settings.privatePublishSettings.privatePublishSettingsData;
//    XCTAssertTrue([five isEqualToDictionary:publishSettings], @"manual copy: %@ did not match publishSettings: %@", five, publishSettings);
    
    [self runTestsFromSettingsAgainstManualCopyOfTargetVersion:five];

}

- (void) testOverridePublishSettingsURLForHTMLSource {
    
    self.configuration = [TEALTestHelper configFromTestHTMLFile:@"collect_ON"];
    
    [self fetchNewSettingsWithConfig:self.configuration];
    
    NSDictionary *manualCopy = @{
                                 @"5": @{
                                         @"_is_enabled":@"true",
                                         @"battery_saver":@"true",
                                         @"dispatch_expiration":@"-1",
                                         @"enable_collect":@"true",
                                         @"enable_s2s_legacy":@"false",
                                         @"enable_tag_management":@"false",
                                         @"event_batch_size":@"1",
                                         @"minutes_between_refresh":@"0.0",
                                         @"offline_dispatch_limit":@"100",
                                         @"override_log":@"",
                                         @"wifi_only_sending":@"false"
                                         },
                                 @"_firstPublish":@"true"
                                 };
    
    NSDictionary *five = manualCopy[@"5"];
    
    NSDictionary *publishSettings = self.settings.privatePublishSettings.privatePublishSettingsData;
    
    XCTAssertTrue([five isEqualToDictionary:publishSettings], @"manual copy: %@ did not match publishSettings: %@", five, publishSettings);
    
    [self runTestsFromSettingsAgainstManualCopyOfTargetVersion:five];
    
}

- (void) fetchNewSettingsWithConfig:(TEALConfiguration*) config {
    
    TEALURLSessionManager *sessionManager = [[TEALURLSessionManager alloc] initWithConfiguration:nil];
    
    self.settings = [[TEALSettings alloc] initWithConfiguration:config];
    
    self.settings.urlSessionManager = sessionManager;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"override"];
    
    [self.settings fetchNewRawPublishSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"%s success:%@, error:%@", __FUNCTION__, success?@"YES":@"NO", error);
        
        [expectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
}

- (void) runTestsFromSettingsAgainstManualCopyOfTargetVersion:(NSDictionary *) manualTargetPublishSetting {
    
    // Testing only core data - see module tests for testing against added methods
    
    // is_enabled
    XCTAssertTrue([manualTargetPublishSetting[TEALPublishSettingKeyIsEnabled] isEqualToString:[self.settings libraryShouldDisable]?@"false":@"true"], @"is_enabled settings did not match");
    
    // battery_saver
    BOOL batterySaverSettings = [self.settings goodBatteryLevelOnlySending];
    BOOL batterySaverTarget = [manualTargetPublishSetting[TEALPublishSettingKeyLowBatteryMode] boolValue];
    
    XCTAssertTrue(batterySaverSettings == batterySaverTarget, @"battery_saver settings did not match: setting:%@ manual:%@", batterySaverSettings?@"true":@"false", batterySaverTarget?@"true":@"false");
    
    // dispatch_expiration
    NSString *expirationString = [NSString stringWithFormat:@"%.0f", [self.settings daysDispatchesValid]];
    
    XCTAssertTrue([manualTargetPublishSetting[TEALPublishSettingKeyDispatchExpiration] isEqualToString:expirationString], @"dispatch_expiration settings did not match");
    
    // event_batch_size
    int targetBatchSize = [manualTargetPublishSetting[TEALPublishSettingKeyDispatchSize] intValue];
    
    XCTAssertTrue([self.settings dispatchSize] == targetBatchSize, @"event_batch_size settings did not match");
    
    // minutes_between_refresh
    double minutesSettings = [self.settings minutesBetweenRefresh];
    double minutesTarget = [manualTargetPublishSetting[TEALPublishSettingKeyMinutesBetweenRefresh] doubleValue];
    XCTAssertTrue(minutesSettings == minutesTarget, @"minutes_between_refresh settings did not match - setting:%f manual:%f", minutesSettings, minutesTarget);

    // offline_dispatch_limit
    int offlineLimit = [manualTargetPublishSetting[TEALPublishSettingKeyOfflineDispatchSize] intValue];
    XCTAssertTrue([self.settings offlineDispatchQueueSize] == offlineLimit, @"offline_dispatch_limit settings did not match");

    // override_log
    NSString *overrideLogSettings = [self.settings.publishSettings overrideLogLevel];
    NSString *overrideLogTarget = manualTargetPublishSetting[TEALPublishSettingKeyOverrideLog];
    
    // normalize
    if ([overrideLogTarget isEqualToString:@""]) overrideLogTarget = nil;
    
    if (overrideLogSettings &&
        overrideLogTarget){
        
        XCTAssertTrue([overrideLogSettings isEqualToString:overrideLogTarget], @"override_log settings did not match - setting:%@ manual:%@", overrideLogSettings, overrideLogTarget);
    
    } else if (!overrideLogSettings &&
               !overrideLogTarget){
        
        // nothing - simpler than 2 checks for either or but not both
        
    } else {
        XCTFail(@"override_log settings did not match - setting:%@ manual:%@", overrideLogSettings, overrideLogTarget);
    }
    
    // wifi_only_sending
    BOOL wifiOnly = [manualTargetPublishSetting[TEALPublishSettingKeyWifiOnlyMode] boolValue];
    XCTAssertTrue([self.settings wifiOnlySending] == wifiOnly, @"wifi_only_sending settings did not match");

    
}

//- (void) testDefaultDispatchURLString {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                              profile:@"demo"
//                                                          environment:@"dev"];
//    
//    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
//    
//    NSString *defaultURLString = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=main";
//    
//    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
//    XCTAssertTrue([[self.settings collectDispatchURLString] isEqualToString:defaultURLString], @"Default dispatch URL returned unexpected string: %@", [self.settings collectDispatchURLString]);
//}

//- (void) testDispatchURLStringOverride {
//    
//    NSString *urlString = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=main&tealium_vid=";
//
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:@"demo"
//                                                         environment:@"dev"];
//    self.configuration.overrideCollectDispatchURL = urlString;
//    
//    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
//    XCTAssertTrue([[self.settings collectDispatchURLString] isEqualToString:urlString], @"Override dispatch URL string not as expected: %@", [self.settings collectDispatchURLString]);
//}




#pragma mark - PUBLISH SETTINGS


@end
