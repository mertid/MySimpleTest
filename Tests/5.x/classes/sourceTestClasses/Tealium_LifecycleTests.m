//
//  TealiumLifecycleTests.h
//  TealiumLifecycleTests
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Tealium+Lifecycle+PrivateHeader.h"
#import "TEALDataSourceConstants.h"
#import "TEALLifecycleDataSources.h"
#import "TEALTestHelper.h"

@interface Tealium_LifecycleTests : XCTestCase<TealiumDelegate>

@property Tealium *tealiumInstance;
@property NSMutableArray *queuedDispatches;
@property XCTestExpectation *queueExpectation;

@end

NSString * const TealiumLifecycleTestID = @"test";

@implementation Tealium_LifecycleTests

- (void)setUp {
    
    [super setUp];
    
    self.queuedDispatches = [NSMutableArray array];
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"test"
                                                                    profile:@"test"
                                                                environment:@"prod"];
    
    self.tealiumInstance = [Tealium newInstanceForKey:TealiumLifecycleTestID
                                        configuration:config];
    
    [self.tealiumInstance setDelegate:self];
    
}

- (void)tearDown {
    
    self.queueExpectation = nil;
    [self.queuedDispatches removeAllObjects];
    [self.tealiumInstance resetLifecycleData];
    [Tealium destroyInstanceForKey:TealiumLifecycleTestID];

    [super tearDown];
}


#pragma mark - TESTS

- (void) testInitialCurrentLifecycleDataSources {
    
    // Does not test persistent data sources, only the volatiles
    
    int unixTimestamp = 1;
    
    // Get the lifecycle data for the given timestamp
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimestamp];
    NSDictionary *lifecycleDataSources = [self.tealiumInstance currentLifecycleDataSources:date];
    
    // Get the expected lifecycle data from a json file
//    NSDictionary *allSampleData = [self dictionaryFromJSONFile:@"lifecycle_sample_volatile_data"];
    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_sample_volatile_data"];
    int timezoneoffset = ((int)[[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
    NSString *offset = [NSString stringWithFormat:@"%i", timezoneoffset];
    NSString *timestampString = [NSString stringWithFormat:@"%i", unixTimestamp];
    NSDictionary *targetSampleData = allSampleData[offset][timestampString];
    
    // Cycle through each key / value so we know exactly which is incorrect, if any
    for (NSString *key in [targetSampleData allKeys]) {
        
        NSString *value = lifecycleDataSources[key];
        if (!value) value = @"";
        
        NSString *expectedValue = targetSampleData[key];
        
        XCTAssertTrue([value isEqualToString:expectedValue], @"Key:%@ \n Retured Value:%@ \n Expected Value:%@", key, value, expectedValue);
        
    }
    
}

- (void) testIncrementLifetimeValuesForKeys {
    
    NSString *testKey = @"testKey";
    int testAmount = 10;
    
    [self.tealiumInstance incrementLifetimeValuesForKeys:@[testKey] amount:testAmount];
    
    // TODO: Why is there a momentary delay here in the persistence data being write / read
    
    BOOL neverFulfilled = NO;
    
    [TEALTestHelper waitFor:&neverFulfilled timeout:0.5];
    
    NSDictionary *persistentData = [self.tealiumInstance persistentDataSourcesCopy];

    NSString *testValue = persistentData[testKey];

    XCTAssertTrue([testValue intValue] == testAmount, @"Incorrect test value returned: %@", testValue);
    
    // cleanup
    [self.tealiumInstance removePersistentDataSourcesForKeys:@[testKey]];
}

- (void) testLaunch {
    
    // Setup
    self.queueExpectation = [self expectationWithDescription:@"queueDispatch"];
    int unixTimestampLaunch = 1;
    
    // Trigger a launch event
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimestampLaunch];
        
    [self.tealiumInstance executeLifecycleCommandForType:TEALLifecycleTypeLaunch
                                            overrideDate:date
                                             autoTracked:NO];
    
    // Get the expected lifecycle data from a json file
    NSDictionary *targetSampleData = [self targetSampleDataForUnixTimestamp:unixTimestampLaunch];
    
    // Dispatches are processed in the background, so wait for completion
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Retrieve the lifecycle data from the dispatch payload
    TEALDispatch *dispath = self.queuedDispatches[0];
    NSDictionary *payload = dispath.payload;
    
    // Cycle through each key / value from sample against the dispatch payload
    // so we know exactly which is incorrect, if any.
    
    for (NSString *key in [targetSampleData allKeys]) {
        
        NSString *value = [NSString stringWithFormat:@"%@",payload[key]];
        if (!value || value == NULL) value = @"";
        
        NSString *expectedValue = [NSString stringWithFormat:@"%@", targetSampleData[key]];
        
        XCTAssertTrue([value isEqualToString:expectedValue], @"Key:%@ \n Retured Value:%@ \n Expected Value:%@", key, value, expectedValue);
        
    }
    
}

- (void) testWake {
    
    // Setup
    self.queueExpectation = [self expectationWithDescription:@"queueDispatch"];
    int unixTimestamp = 3;
    
    // Seed the instance with expected prior data
    NSDictionary *priorSampleData = [self targetSampleDataForUnixTimestamp:(unixTimestamp - 1)];
    [self.tealiumInstance addPersistentDataSources:priorSampleData];
    
    // Trigger a wake event
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimestamp];
    [self.tealiumInstance executeLifecycleCommandForType:TEALLifecycleTypeWake
                                            overrideDate:date
                                             autoTracked:NO];
    
    // Get the expected lifecycle data from a json file
    NSDictionary *targetSampleData = [self targetSampleDataForUnixTimestamp:unixTimestamp];
    
    // Dispatches are processed in the background, so wait for completion
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Retrieve the lifecycle data from the dispatch payload
    TEALDispatch *dispath = self.queuedDispatches[0];
    NSDictionary *payload = dispath.payload;
    
    // Cycle through each key / value from sample against the dispatch payload
    // so we know exactly which is incorrect, if any.
    
    for (NSString *key in [targetSampleData allKeys]) {
        
        NSString *value = [NSString stringWithFormat:@"%@",payload[key]];
        if (!value || value == NULL) value = @"";
        
        NSString *expectedValue = [NSString stringWithFormat:@"%@", targetSampleData[key]];
        
        XCTAssertTrue([value isEqualToString:expectedValue], @"Key:%@ \n Retured Value:%@ \n Expected Value:%@", key, value, expectedValue);
        
    }
    
}

- (void) testSleep {
    
    // Setup
    self.queueExpectation = [self expectationWithDescription:@"queueDispatch"];
    int unixTimestamp = 2;
    
    // Seed the instance with expected prior data
    NSDictionary *priorSampleData = [self targetSampleDataForUnixTimestamp:(unixTimestamp - 1)];
    [self.tealiumInstance addPersistentDataSources:priorSampleData];
    
    // Trigger a sleep event
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimestamp];
    [self.tealiumInstance executeLifecycleCommandForType:TEALLifecycleTypeSleep
                                            overrideDate:date
                                             autoTracked:NO];
    
    // Get the expected lifecycle data from a json file
    NSDictionary *targetSampleData = [self targetSampleDataForUnixTimestamp:unixTimestamp];
    
    // Dispatches are processed in the background, so wait for completion
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Retrieve the lifecycle data from the dispatch payload
    TEALDispatch *dispath = self.queuedDispatches[0];
    NSDictionary *payload = dispath.payload;
    
    // Cycle through each key / value from sample against the dispatch payload
    // so we know exactly which is incorrect, if any.
    
    for (NSString *key in [targetSampleData allKeys]) {
        
        NSString *value = [NSString stringWithFormat:@"%@",payload[key]];
        if (!value || value == NULL) value = @"";
        
        NSString *expectedValue = [NSString stringWithFormat:@"%@", targetSampleData[key]];
        
        XCTAssertTrue([value isEqualToString:expectedValue], @"Key:%@ \n Returned Value:%@ \n Expected Value:%@", key, value, expectedValue);
        
    }
    
}

- (void) testLongRunningEvents {
    
    // Going to test input and outputs over 1000 sequential launch/sleep/wake events
    NSArray *sampleData = [self longRunningTestData];
    
    NSMutableDictionary *persistentDataMock = [NSMutableDictionary dictionary];
    
//    for (int i = 0; i < [sampleData count]; i++) {
    for (int i = 0; i < 30; i++) {
    
        NSDictionary *expectedData = sampleData[i][@"expected_data"];
        
        NSString *type = expectedData[TEALDataSourceKey_LifecycleType];
    
        // Override our App version number with the sample version
        
        if (i == 0){
            NSString *appVersion = sampleData[i][TEALDataSourceKey_ApplicationVersion];
            
            [persistentDataMock addEntriesFromDictionary:@{
                                                           TEALDataSourceKey_ApplicationVersion : appVersion
                                                           }];
        }
        
        
        // Use the date of test event
        NSString *unixString = sampleData[i][TEALDataSourceKey_TimestampUnix];
        NSInteger unixInterval = [unixString integerValue];
        NSDate *unixDate = [NSDate dateWithTimeIntervalSince1970:unixInterval];
        
        XCTAssertTrue(unixDate, @"Could not retrieve date from sample data.");
        
        TEALLifecycleType lifecycleType = [Tealium lifecycleTypeFromString:type];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        
        [data addEntriesFromDictionary:persistentDataMock];
        
        NSDictionary *lifecycleData = [self.tealiumInstance newLifecycleDataSourcesForType:lifecycleType
                                                                                      date:unixDate
                                                                            persistentData:persistentDataMock];
        
        [data addEntriesFromDictionary:lifecycleData];
    
#warning daysSinceLaunch & priorsecondsawake are not returning the expected values
        
        for (NSString *key in [expectedData allKeys]) {
            
            NSString *value = [NSString stringWithFormat:@"%@",data[key]];
            if (!value || value == NULL) value = @"";
            
            NSString *expectedValue = [NSString stringWithFormat:@"%@", expectedData[key]];
            
            XCTAssertTrue([value isEqualToString:expectedValue], @"Discrepancy in record %i (%@)\n Key:%@ \n Returned Value:%@ \n Expected Value:%@", i, unixString, key, value, expectedValue);
            
        }
        
        NSDictionary *updateData = [self.tealiumInstance updatePersistentDataSourcesForType:lifecycleType
                                                                                       date:unixDate
                                                                             persistentData:persistentDataMock];
        
        [persistentDataMock addEntriesFromDictionary:updateData];
        
    }
    
}


#pragma mark - TEALIUM DELEGATE

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    [self.queuedDispatches addObject:dispatch];
    
    [self.queueExpectation fulfill];
}

#pragma mark - HELPERS

- (NSDictionary *) targetSampleDataForUnixTimestamp:(int)ts {
    
    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_sample_data"];
    int timezoneoffset = ((int)[[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
    NSString *offset = [NSString stringWithFormat:@"%i", timezoneoffset];
    NSString *timestampString = [NSString stringWithFormat:@"%i", ts];
    NSDictionary *targetSampleData = allSampleData[offset][timestampString];
    
    return targetSampleData;
    
}

- (NSArray *) longRunningTestData {
    
    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_events"];
    NSArray *events = allSampleData[@"events"];
    
    return events;

}


// Use TEALTestHelpers version instead

//- (NSDictionary *) dictionaryFromJSONFile:(NSString *)filename {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    BOOL exists = [fileManager fileExistsAtPath:path];
//    
//    NSAssert(exists, @"Test file %@ does not exist at path:%@", filename, path);
//    
//    NSData *data = [fileManager contentsAtPath:path];
//    
//    NSDictionary *resultDictionary = nil;
//    NSError *error;
//    
//    resultDictionary = [NSJSONSerialization JSONObjectWithData:data
//                                                       options:NSJSONReadingAllowFragments
//                                                         error:&error];
//    
//    return resultDictionary;
//    
//}

@end
