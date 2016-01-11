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

@interface TEALPublishSettingsTests : XCTestCase

@property (nonatomic) TEALPublishSettings *publishSettings;

@end

@implementation TEALPublishSettingsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

- (void) testInitWithURL {
    
    NSString *urlString = @"https://www.google.com";

    [self useSamplePublishSettings];

    XCTAssertTrue(self.publishSettings, @"publishSettings did not init");
    
    XCTAssertTrue([self.publishSettings.url isEqualToString:urlString], @"url property did not return expected value.");
    
}

- (void) testMPSDictionaryFromJSONFile {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    XCTAssertTrue(data, @"No data recieved for path:%@", path);
    
    NSError *error = nil;
    
    NSDictionary *mpsData = [TEALPublishSettings mobilePublishSettingsFromJSONFile:data
                                                                             error:&error];

    NSDictionary *manualCopy = @{
        @"5": @{
            @"_is_enabled":@"true",
            @"battery_saver":@"true",
            @"dispatch_expiration":@"-1",
            @"enable_collect":@"true",
            @"enable_s2s_legacy":@"false",
            @"enable_tag_management":@"false",
            @"event_batch_size":@"1",
            @"minutes_between_refresh":@"15.0",
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
                                                                             error:&error];
    
    XCTAssertTrue(!error, @"Error detected:%@", error);
    
    [self useSamplePublishSettings];
    
    self.publishSettings.targetVersion = targetVersion;
    
    [self.publishSettings updateWithRawSettings:mpsData];
    
    NSDictionary *privatePublishData = self.publishSettings.privatePublishSettingsData;
    
    NSDictionary *targetMPSData = mpsData[targetVersion];
    
    XCTAssertTrue([privatePublishData isEqualToDictionary:targetMPSData], @"Discrepancy between publish settings private settings data:%@ and mpsData:%@", privatePublishData, targetMPSData);
    
    // Test values
    
    NSUInteger mpsDispatchSize = [targetMPSData[TEALPublishSettingKeyDispatchSize] integerValue];
    
    XCTAssertTrue([self.publishSettings dispatchSize] == mpsDispatchSize, @"Discrepancy between publish setting dispatch size:%lu and mps dispatch size:%lu", (unsigned long)[self.publishSettings dispatchSize], (unsigned long)mpsDispatchSize);
    
    NSUInteger mpsOfflineQueueSize = [targetMPSData[TEALPublishSettingKeyOfflineDispatchSize] integerValue];
    
    XCTAssertTrue([self.publishSettings offlineDispatchQueueSize] == mpsOfflineQueueSize, @"Discrepancy between publish setting dispatch size:%lu and mps dispatch size:%lu", (unsigned long)[self.publishSettings offlineDispatchQueueSize], (unsigned long)mpsOfflineQueueSize);

}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
