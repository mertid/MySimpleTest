//
//  TEALLifecycleDataSourcesTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TEALLifecycleDataSources.h"

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

@end
