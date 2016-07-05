//
//  TealiumLifecycleTests.m
//  TealiumLifecycleTests
//
//  Created by Jason Koo on 6/1/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tealium+Lifecycle.h"
#import "Tealium.h"
#import "TEALTestHelper.h"

@interface TealiumLifecycleTests : XCTestCase

@end

@implementation TealiumLifecycleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark
#pragma mark - TESTS

//- (void) testLongRunningEvents {
//    
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"account" profile:@"profile" environment:@"env"];
//    
//    Tealium *tealium = [Tealium newInstanceForKey:@"test" configuration:config];
//    
//    // Going to test input and outputs over 1000 sequential launch/sleep/wake events
//    
//    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_events"];
//    NSArray *sampleData = allSampleData[@"events"];
//    
//    NSMutableDictionary *persistentDataMock = [NSMutableDictionary dictionary];
//    
//    //    for (int i = 0; i < [sampleData count]; i++) {
//    for (int i = 0; i < 30; i++) {
//        
//        NSDictionary *expectedData = sampleData[i][@"expected_data"];
//        
//        NSString *type = expectedData[TEALDataSourceKey_LifecycleType];
//        
//        // Override our App version number with the sample version
//        
//        if (i == 0){
//            NSString *appVersion = sampleData[i][TEALDataSourceKey_ApplicationVersion];
//            
//            [persistentDataMock addEntriesFromDictionary:@{
//                                                           TEALDataSourceKey_ApplicationVersion : appVersion
//                                                           }];
//        }
//        
//        
//        // Use the date of test event
//        NSString *unixString = sampleData[i][TEALDataSourceKey_TimestampUnix];
//        NSInteger unixInterval = [unixString integerValue];
//        NSDate *unixDate = [NSDate dateWithTimeIntervalSince1970:unixInterval];
//        
//        XCTAssertTrue(unixDate, @"Could not retrieve date from sample data.");
//        
//        TEALLifecycleType lifecycleType = [Tealium lifecycleTypeFromString:type];
//        
//        NSMutableDictionary *data = [NSMutableDictionary dictionary];
//        
//        [data addEntriesFromDictionary:persistentDataMock];
//        
//        NSDictionary *lifecycleData = [Tealium newLifecycleDataSourcesForType:lifecycleType
//                                                                                      date:unixDate
//                                                                            persistentData:persistentDataMock];
//        
//        [data addEntriesFromDictionary:lifecycleData];
//        
//#warning daysSinceLaunch not returning the expected values
//        
//        for (NSString *key in [expectedData allKeys]) {
//            
//            NSString *value = [NSString stringWithFormat:@"%@",data[key]];
//            if (!value || value == NULL) value = @"";
//            
//            NSString *expectedValue = [NSString stringWithFormat:@"%@", expectedData[key]];
//            
//            XCTAssertTrue([value isEqualToString:expectedValue], @"Discrepancy in record %i (%@)\n Key:%@ \n Returned Value:%@ \n Expected Value:%@", i, unixString, key, value, expectedValue);
//            
//        }
//        
//        NSDictionary *updateData = [tealium updatePersistentDataSourcesForType:lifecycleType
//                                                                          date:unixDate
//                                                                persistentData:persistentDataMock];
//        
//        [persistentDataMock addEntriesFromDictionary:updateData];
//        
//    }
//    
//}
//
////- (void) testNewPersistentDataSourcesForLaunches {
////
////    XCTFail(@"");
////
////}
//
//- (void) testNewVolatileDataSourcesForLaunches {
//    
//    // Pull sample input dictionary from file
//    NSDictionary *volatileData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_sample_data"];
//    NSDictionary *samples = volatileData[@"launches_volatile"];
//    NSArray *sampleKeys = [samples allKeys];
//    
//    for (int i = 0; i < [sampleKeys count]; i++) {
//        
//        NSString *key = sampleKeys[i];
//        
//        NSDictionary *sample = samples[key];
//        
//        NSDictionary *source = sample[@"source"];
//        
//        // Run call with sample source
//        NSTimeInterval unixTime = [key intValue];
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
//        NSDictionary *outputActual = [Tealium newVolatileLifecycleDataSourcesForLaunchesAt:date
//                                                                            persistentData:source];
//        
//        // Pull expected output dictionary from file
//        NSDictionary *outputExpected = sample[@"output"];
//        
//        // Compare actual output with expected
//        BOOL passed = [outputActual isEqualToDictionary:outputExpected];
//        
//        XCTAssertTrue(passed, @"Output actual %@ did not equal output expected %@", outputActual, outputExpected);
//        
//    }
//    
//}

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
