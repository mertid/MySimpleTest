//
//  TEALLifecycleDataSourcesTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TEALLifecycleDataSources.h"
#import "TEALTestHelper.h"

@interface TEALLifecycleDataSourcesTests : XCTestCase

@end

@implementation TEALLifecycleDataSourcesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testDateFromISOString {

    NSString *testISOString = @"2016-03-02T18:52:00Z";
    
    NSDate *date = [TEALLifecycleDataSources dateFromISOString:testISOString];
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    
    NSTimeInterval expectedInterval = 1456944720;
    
    XCTAssertTrue(interval == expectedInterval, @"Unexpected interval returned: %f", interval);
    
}

- (void) testDayOfWeek {
    
    NSDate *firstSecond = [NSDate dateWithTimeIntervalSince1970:1];
    
    NSString *dayOfWeek = [TEALLifecycleDataSources dayOfWeekForDate:firstSecond];
    
    // Should equal UTC Thursday, Wednesday PST
    // 1 = Sunday
    
    int expected = 4;
    int returned = [dayOfWeek intValue];
    
    XCTAssertTrue(returned == expected, @"Day of week for PST should have been %i, %i was returned.", expected, returned);
    
    
}

- (void) testSecondsFromTo {
    
    int earlierInterval = 1;
    int laterInterval = 10;
    
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:earlierInterval];
    
    NSDate *laterDate = [NSDate dateWithTimeIntervalSince1970:laterInterval];
    
    NSString *outputString = [TEALLifecycleDataSources secondsFrom:earlierDate
                                                          to:laterDate];
    
    int expectedOutput = laterInterval - earlierInterval;
    
    NSString *expectedOutputString = [NSString stringWithFormat:@"%i", expectedOutput];

    XCTAssertTrue([outputString isEqualToString:expectedOutputString], @"Unexpected output string: %@", outputString);
    
}


#pragma mark - WAKE TESTS
- (void) testIsFirstWakeToday_NoEarlierDate {
    
    NSTimeInterval unixTime = 118800;  // Jan 2nd 1970 1am Local (PST)

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:nil];
    
    XCTAssertTrue(success);
}

- (void) testIsFirstWakeToday_EarlierDatePastDayStart {
    
    NSTimeInterval unixTime = 118800;
    NSTimeInterval unixTimeEarlier = 117000; // 30 min. prior

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:unixTimeEarlier];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:earlierDate];
    
    // The earlier date is the first wake for today
    XCTAssertTrue(!success);
}

- (void) testIsFirstWakeToday_EarlierDateBeforeDayStart {
    
    NSTimeInterval unixTime = 118800;
    NSTimeInterval unixTimeEarlier = 68400; // Jan 1 1970 11pm
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:unixTimeEarlier];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:earlierDate];
    
    XCTAssertTrue(success);
}

- (void) testIsFirstWakeToday_EarlierDateLaterThanCurrentDate {
    
    NSTimeInterval unixTime = 118800;
    NSTimeInterval unixTimeEarlier = 122400; // 1 hour later
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:unixTimeEarlier];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:earlierDate];
    
    XCTAssertTrue(success);
}

- (void) testIsFirstWakeMonth_NoEarlierDate {
    
    NSTimeInterval unixTime = 2710800;  // 1 Feb 1970 0100 PST
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:nil];
    
    XCTAssertTrue(success);
}

- (void) testIsFirstWakeMonth_EarlierDatePastDayStart {
    
    NSTimeInterval unixTime = 2710800;
    NSTimeInterval unixTimeEarlier = 2709000; // 30 min. prior
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:unixTimeEarlier];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:earlierDate];
    
    XCTAssertTrue(!success);
}

- (void) testIsFirstWakeMonth_EarlierDateBeforeDayStart {
    
    NSTimeInterval unixTime = 2710800;
    NSTimeInterval unixTimeEarlier = 2617200; // 30 Jan 1970 2300 PST
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:unixTimeEarlier];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:earlierDate];
    
    XCTAssertTrue(success);
}

- (void) testIsFirstWakeMonth_EarlierDateLaterThanCurrentDate {
    
    NSTimeInterval unixTime = 2710800;
    NSTimeInterval unixTimeEarlier = 2714400; // hour later
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDate *earlierDate = [NSDate dateWithTimeIntervalSince1970:unixTimeEarlier];
    
    BOOL success = [TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                           priorDate:earlierDate];
    
    XCTAssertTrue(success);
}

- (void) testMostRecentDateFromPersistentData {
    
    NSDictionary *persistentData = @{
                                     TEALDataSourceKey_LifecycleLastSleepDate : @"1970-02-02T09:04:39Z",
                                     TEALDataSourceKey_LifecycleLastLaunchDate : @"1970-01-13T09:32:41Z",
                                     TEALDataSourceKey_LifecycleLastWakeDate : @"1970-02-08T14:13:12Z"
                                     };
    
    TEALLifecycleType type = [TEALLifecycleDataSources mostRecentDateFromPersistentData:persistentData];
    
    XCTAssertTrue(type == TEALLifecycleTypeWake, @"Incorrect type returned: %@", [TEALLifecycleDataSources stringFromLifecyleType:type]);

}



#pragma mark - LONG RUNNING TESTS

- (void) testLongRunningEvents {

    // Going to test input and outputs over 1000 sequential launch/sleep/wake events
    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_events"];
    NSArray *sampleData = allSampleData[@"events"];

    NSMutableDictionary *persistentDataMock = [NSMutableDictionary dictionary];

    for (int i = 0; i < [sampleData count]; i++) {
//    for (int i = 0; i < 670; i++) {

        NSDictionary *expectedData = sampleData[i][@"expected_data"];

        NSString *type = expectedData[TEALDataSourceKey_LifecycleType];

        // Override internal app version update detection
        NSString *appVersion = sampleData[i][TEALDataSourceKey_ApplicationVersion];
        
        if (i>0){
            NSString *priorVersion = sampleData[i-1][TEALDataSourceKey_ApplicationVersion];
            if (![appVersion isEqualToString:priorVersion]){
                persistentDataMock[TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate] = @"true";
            }
        } else {
            persistentDataMock[TEALDataSourceKey_ApplicationVersion] = appVersion;
        }


        // Use the date of test event
        NSString *unixString = sampleData[i][TEALDataSourceKey_TimestampUnix];
        NSInteger unixInterval = [unixString integerValue];
        NSDate *unixDate = [NSDate dateWithTimeIntervalSince1970:unixInterval];

        XCTAssertTrue(unixDate, @"Could not retrieve date from sample data.");
        
        TEALLifecycleType lifecycleType = [TEALLifecycleDataSources lifecycleTypeFromString:type];

        NSMutableDictionary *data = [NSMutableDictionary dictionary];

        [data addEntriesFromDictionary:persistentDataMock];

        NSDictionary *lifecycleData = [TEALLifecycleDataSources newLifecycleDataSourcesForType:lifecycleType
                                                                                      date:unixDate
                                                                            persistentData:persistentDataMock];

        [data addEntriesFromDictionary:lifecycleData];


        for (NSString *key in [expectedData allKeys]) {

            NSString *value = [NSString stringWithFormat:@"%@",data[key]];
            if (!value || value == NULL) value = @"";

            NSString *expectedValue = [NSString stringWithFormat:@"%@", expectedData[key]];

            XCTAssertTrue([value isEqualToString:expectedValue], @"Discrepancy in record %i (%@)\n Key:%@ \n Returned Value:%@ \n Expected Value:%@", i, unixString, key, value, expectedValue);

        }

        NSDictionary *updateData = [TEALLifecycleDataSources updatePersistentDataSourcesForType:lifecycleType
                                                                                       date:unixDate
                                                                             persistentData:persistentDataMock];

        [persistentDataMock addEntriesFromDictionary:updateData];
        
        // Reset any app version update trigger
        [persistentDataMock removeObjectForKey:TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate];

    }

}


- (void) testLongRunningEventsWithCrashes {
    
    // Going to test input and outputs over 1000 sequential launch/sleep/wake events
    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"lifecycle_events_with_crashes"];
    NSArray *sampleData = allSampleData[@"events"];
    
    NSMutableDictionary *persistentDataMock = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < [sampleData count]; i++) {
//            for (int i = 0; i < 22; i++) {
        
        NSDictionary *expectedData = sampleData[i][@"expected_data"];
        
        NSString *type = expectedData[TEALDataSourceKey_LifecycleType];
        
        // Override internal app version update detection
        NSString *appVersion = sampleData[i][TEALDataSourceKey_ApplicationVersion];
        
        if (i>0){
            NSString *priorVersion = sampleData[i-1][TEALDataSourceKey_ApplicationVersion];
            if (![appVersion isEqualToString:priorVersion]){
                persistentDataMock[TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate] = @"true";
            }
        } else {
            persistentDataMock[TEALDataSourceKey_ApplicationVersion] = appVersion;
        }
        
        
        // Use the date of test event
        NSString *unixString = sampleData[i][TEALDataSourceKey_TimestampUnix];
        NSInteger unixInterval = [unixString integerValue];
        NSDate *unixDate = [NSDate dateWithTimeIntervalSince1970:unixInterval];
        
        XCTAssertTrue(unixDate, @"Could not retrieve date from sample data.");
        
        TEALLifecycleType lifecycleType = [TEALLifecycleDataSources lifecycleTypeFromString:type];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        
        [data addEntriesFromDictionary:persistentDataMock];
        
        NSDictionary *lifecycleData = [TEALLifecycleDataSources newLifecycleDataSourcesForType:lifecycleType
                                                                                          date:unixDate
                                                                                persistentData:persistentDataMock];
        
        [data addEntriesFromDictionary:lifecycleData];
        
        
        for (NSString *key in [expectedData allKeys]) {
            
            NSString *value = [NSString stringWithFormat:@"%@",data[key]];
            if (!value || value == NULL) value = @"";
            
            NSString *expectedValue = [NSString stringWithFormat:@"%@", expectedData[key]];
            
            XCTAssertTrue([value isEqualToString:expectedValue], @"Discrepancy in record %i (%@)\n Key:%@ \n Returned Value:%@ \n Expected Value:%@", i, unixString, key, value, expectedValue);
            
        }
        
        NSDictionary *updateData = [TEALLifecycleDataSources updatePersistentDataSourcesForType:lifecycleType
                                                                                           date:unixDate
                                                                                 persistentData:persistentDataMock];
        
        [persistentDataMock addEntriesFromDictionary:updateData];
        
        // Reset any app version update trigger
        [persistentDataMock removeObjectForKey:TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate];
        
    }
    
}

@end
