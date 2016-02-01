//
//  TEALPublishSettingsTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import <XCTest/XCTest.h>
#import "TEALPublishSettingsConstants.h"
#import "TEALPublishSettings+PrivateHeader.h"
#import "TEALTestHelper.h"

@interface TEALPublishSettingsTests : XCTestCase

@property (nonatomic) TEALPublishSettings *publishSettings;

@end

@implementation TEALPublishSettingsTests

- (void)setUp {
    [super setUp];
    
    NSString *settings1 = @"publishSettingsTests";
    
    self.publishSettings = [[TEALPublishSettings alloc] initWithURLString:settings1];
    
}

- (void)tearDown {
    self.publishSettings = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) useSamplePublishSettings {
    
    NSString *urlString = @"https://www.google.com";
    
    self.publishSettings = [[TEALPublishSettings alloc] initWithURLString:urlString];
    
}

- (NSDictionary *) sampleSettings {
    
    return @{
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
             };
    
}

#pragma mark - TESTS

- (void) testInitWithURL {
    
    NSString *urlString = @"https://www.google.com";

    [self useSamplePublishSettings];

    XCTAssertTrue(self.publishSettings, @"publishSettings did not init");
    
    XCTAssertTrue([self.publishSettings.url isEqualToString:urlString], @"url property did not return expected value - publishSetting:%@ testURLString:%@", [self.publishSettings url], urlString);
    
}

- (void) testMPSDictionaryFromJSONFile {
    
    // Test files need to be added in Test target's Build Phases: Copy Bundle Resources
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    XCTAssertTrue(data, @"No data recieved for path:%@", path);
    
    NSError *error = nil;
    
    NSDictionary *mpsData = [TEALPublishSettings mobilePublishSettingsFromJSONFile:data
                                                                             error:error];

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
    
    XCTAssertTrue(!error, @"Error detected:%@", error);
    
    XCTAssertTrue([mpsData isEqualToDictionary:manualCopy], @"Discrepancy between mps data:%@ and manualCopy: %@", mpsData, manualCopy);
    
    
}

- (void) testUpdateRawSettings {
    
    NSString *targetVersion = @"5";
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    XCTAssertTrue(data, @"No data recieved for path:%@", path);
    
    NSError *error = nil;
    
    NSDictionary *mpsData = [TEALPublishSettings mobilePublishSettingsFromJSONFile:data
                                                                             error:error];
    
    XCTAssertTrue(!error, @"Error detected:%@", error);
    
    [self useSamplePublishSettings];
    
//    self.publishSettings.targetVersion = targetVersion;
    
    [self.publishSettings updateWithMatchingVersionSettings:mpsData[@"5"]];
    
    
    NSDictionary *privatePublishData = self.publishSettings.privatePublishSettingsData;
    
    NSDictionary *targetMPSData = mpsData[targetVersion];
    
    XCTAssertTrue([privatePublishData isEqualToDictionary:targetMPSData], @"Discrepancy between publish settings private settings data:%@ and mpsData:%@", privatePublishData, targetMPSData);
    
    // Test values
    
    NSUInteger mpsDispatchSize = [targetMPSData[TEALPublishSettingKeyDispatchSize] integerValue];
    
    XCTAssertTrue([self.publishSettings dispatchSize] == mpsDispatchSize, @"Discrepancy between publish setting dispatch size:%lu and mps dispatch size:%lu", (unsigned long)[self.publishSettings dispatchSize], (unsigned long)mpsDispatchSize);
    
    NSUInteger mpsOfflineQueueSize = [targetMPSData[TEALPublishSettingKeyOfflineDispatchSize] integerValue];
    
    XCTAssertTrue([self.publishSettings offlineDispatchQueueSize] == mpsOfflineQueueSize, @"Discrepancy between publish setting dispatch size:%lu and mps dispatch size:%lu", (unsigned long)[self.publishSettings offlineDispatchQueueSize], (unsigned long)mpsOfflineQueueSize);

}

- (void) testArchiving {
    
    NSString *settings1 = @"settings1";
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:settings1];

    [settings updateWithMatchingVersionSettings:[self sampleSettings]];
    
    NSString *settings2 = @"settings2";
    
    TEALPublishSettings *altSettings = [[TEALPublishSettings alloc] initWithURLString:settings2];
    
    XCTAssertTrue(![settings isEqualToPublishSettings:altSettings], @"Should not have matched - settings:%@  altSettings:%@", settings, altSettings);
    
    TEALPublishSettings *retrievedSettings = [TEALPublishSettings archivedPublishSettingForURL:settings1];
    
    XCTAssertTrue([settings isEqualToPublishSettings:retrievedSettings], @"Settings:%@ was not equal to Unarchived settings:%@", settings, retrievedSettings);
    
}

- (void) testPurgeArchive {
    
    NSString *settings1 = @"settings1";
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:settings1];
    
    [settings updateWithMatchingVersionSettings:[self sampleSettings]];
    
    [TEALPublishSettings purgeAllArchives];
    
    TEALPublishSettings *defaultSettings = [[TEALPublishSettings alloc] initWithURLString:settings1];
    
    XCTAssertTrue([defaultSettings isEqualToPublishSettings:[TEALPublishSettings defaultPublishSettingsForURLString:settings1]], @"settings did not purge as expected.");
    
}

- (void) testCurrentSettingsFromRawPublishSettings {
    
    NSDictionary *mps = [TEALTestHelper dictionaryFromJSONFile:@"library_MISSING"];
    
    NSDictionary *mpsRetrieved = [self.publishSettings currentPublishSettingsFromRawPublishSettings:mps];
    
    XCTAssertTrue(!mpsRetrieved, @"MPS data retrieved when none should have: %@", mpsRetrieved);
    
    
    NSDictionary *mpsOFF = [TEALTestHelper dictionaryFromJSONFile:@"library_OFF"];
    
    NSDictionary *mpsOFFRetrieved = [self.publishSettings currentPublishSettingsFromRawPublishSettings:mpsOFF];
    
    XCTAssertTrue(mpsOFFRetrieved, @"MPS data note retrieved when should have: %@", mpsOFFRetrieved);
    
    
}

@end
