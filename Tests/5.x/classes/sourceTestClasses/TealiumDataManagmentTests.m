//
//  TealiumDataManagmentTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 12/21/15.
//  Copyright © 2015 f. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"

@interface TealiumDataManagmentTests : XCTestCase

@property Tealium *library;

@end

@implementation TealiumDataManagmentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - HELPERS

- (void) useLiveLibraryInstance {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
    
    __block BOOL fullfilled = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       if (!fullfilled){
                                           [expectation fulfill];
                                           fullfilled = YES;
                                        }
                                       
                                   }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!*flag);
    return *flag;
}

- (NSDictionary *) stringDataSources {
    
    NSString *testKey = TEAL_TEST_DATASOURCE_KEY;
    NSString *testValue = TEAL_TEST_DATASOURCE_STRING_VALUE;
    
    NSDictionary *testDataSources = @{
                                      testKey : testValue
                                      };
    return testDataSources;
    
}


- (NSDictionary *) mixedDataSources {
    
    NSString *testKey = TEAL_TEST_DATASOURCE_KEY;
    NSString *testValue = TEAL_TEST_DATASOURCE_STRING_VALUE;
    
    NSString * testNumberKey = @"testNumberKey";
    NSNumber * testNumber = @1234;
    
    NSDictionary *testDataSources = @{
                                      testKey : testValue,
                                      testNumberKey : testNumber
                                      };
    return testDataSources;
}


- (NSDictionary *) dataSourcesWithTimestampUnixOverride {
    
    
    NSString *testKey = TEAL_TEST_DATASOURCE_KEY;
    NSString *testValue = TEAL_TEST_DATASOURCE_STRING_VALUE;
    
    NSDictionary *testDataSources = @{
                                      testKey : testValue,
                                      TEALDataSourceKey_TimestampUnix : @0
                                      
                                      };
    return testDataSources;
    
    
}

#pragma mark - TESTS

//- (void) testDefaultViewDataSources {
//    
//    /*
//     DEFAULT DATASOURCES for 5.0.0
//     
//     "app_name" = TealiumiOSCore;
//     "app_rdns" = "com.tealium.TealiumiOSCore";
//     "app_version" = "1.0";
//     callType = view;
//     "connection_type" = wifi;
//     device = iPhone;
//     "device_architecture" = 64;
//     "device_battery_percent" = "-100";
//     "device_cputype" = "x86 ";
//     “device_ischarging” = false;
//     "device_language" = en;
//     "device_orientation" = "Landscape Left";
//     "device_os_version" = "9.0";
//     "device_resolution" = 750x1334;
//     "library_version" = "5.0";
//     orientation = "Landscape Left";
//     origin = mobile;
//     "os_version" = "9.0";
//     "page_type" = "mobile_view";
//     platform = iOS;
//     "screen_title" = APITester;
//     timestamp = "2015-11-06T19:16:43Z";
//     "timestamp_local" = "2015-11-06T11:16:43";
//     "timestamp_offset" = "-8";
//     "timestamp_unix" = 1446837403;
//     uuid = "F7B3E56C-86D1-4559-B620-791ABA998FFD";
//     "visitor_id" = F7B3E56C86D14559B620791ABA998FFD;
//     */
//    
//    [self useLiveLibraryInstance];
//    
//    NSDictionary *dataSources = [self.library finalDispatchDataSourcesForDispatchType:TEALDispatchTypeView title:@"title" dataSources:nil];
//    
//    for (NSString *key in [TEALTestHelper defaultViewDataSourceKeys]) {
//        
//        id value = dataSources[key];
//        
//        XCTAssertTrue(value, @"Key missing from default data sources from library: %@", key);
//        
//    }
//    
//}
//
//- (void) testDefaultEventDataSources {
//    
//    [self useLiveLibraryInstance];
//    
//    NSDictionary *dataSources = [self.library finalDispatchDataSourcesForDispatchType:TEALDispatchTypeEvent title:@"title" dataSources:nil];
//    
//    for (NSString *key in [TEALTestHelper defaultEventDataSourceKeys]) {
//        
//        id value = dataSources[key];
//        
//        XCTAssertTrue(value, @"Key missing from default data sources from library:%@", key);
//        
//    }
//    
//}


#pragma mark - TESTS

#pragma mark - VOLATILE


- (void) testAddAndRemoveVolatileDataSource {
    
    __block BOOL isReady = NO;
    
    Tealium *instance = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       isReady = YES;
                                       
                                   }];
    
    NSDictionary *testDataSources = [self stringDataSources];
    
    [self waitFor:&isReady timeout:1.0];
    
    isReady = NO;

    [instance addVolatileDataSources:testDataSources];
    
    // There will be a short delay here on this thread as the above method is
    // sent to the end of the Tealium BG serial queue
    [self waitFor:&isReady timeout:1.0];
    
    NSDictionary *dataSourcesRetrieved = [instance volatileDataSourcesCopy];
    
    XCTAssertTrue(dataSourcesRetrieved[TEAL_TEST_DATASOURCE_KEY], @"volatile data was not added.");
    
    XCTAssertTrue([dataSourcesRetrieved[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"volatile data was not added.");
    
    XCTAssertTrue([dataSourcesRetrieved isEqualToDictionary:testDataSources], @"volatile data sources %@ did not match test data sources: %@", dataSourcesRetrieved, testDataSources);
    
    [instance removeVolatileDataSourcesForKeys:@[TEAL_TEST_DATASOURCE_KEY]];
    
    // No callback to flip the flag, so we'll always timeout
    [self waitFor:&isReady timeout:0.5];
    
    // There will be a short delay here on this thread as the above method is
    // sent to the end of the Tealium BG serial queue
    
    XCTAssertTrue(![instance volatileDataSourcesCopy][TEAL_TEST_DATASOURCE_KEY], @"volatile data was not removed.");
    
    XCTAssertTrue([dataSourcesRetrieved isEqualToDictionary:testDataSources], @"volatile data sources %@ did not match test data sources: %@", dataSourcesRetrieved, testDataSources);

}



#pragma mark - PERSISTENT


- (void) testAddAndRemovePersistentDataSources {
    
    [self useLiveLibraryInstance];
    
    NSDictionary *testData = [self stringDataSources];
    
    [self.library addPersistentDataSources:testData];
    
    __block BOOL isAddReady = NO;
    
    // No callback to flip the flag, so we'll always timeout
    
    [self waitFor:&isAddReady timeout:1.0];
    
    NSDictionary *dataSourcesRetrieved = [self.library persistentDataSourcesCopy];
    
    XCTAssertTrue([dataSourcesRetrieved[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"persistent data was not added.");
    
    [self.library removePersistentDataSourcesForKeys:@[TEAL_TEST_DATASOURCE_KEY]];
    
    __block BOOL isRemoveReady = NO;
    
    // No callback to flip the flag, so we'll always timeout
    
    [self waitFor:&isRemoveReady timeout:1.0];
    
    // There will be a short delay here on this thread as the above method is
    // sent to the end of the Tealium BG serial queue
    
    XCTAssertTrue(![self.library persistentDataSourcesCopy][TEAL_TEST_DATASOURCE_KEY], @"volatile data was not removed.");
    
}

@end
