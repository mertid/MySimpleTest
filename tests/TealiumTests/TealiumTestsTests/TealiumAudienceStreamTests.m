//
//  TealiumAudienceStreamTests.m
//  TealiumTests
//
//  Created by Jason Koo on 7/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <Tealium/Tealium.h>
#import <Tealium/TEALSettings.h>
#import "Tealium+PrivateTestHeader.h"

@interface TealiumAudienceStreamTests : XCTestCase

@property (strong) Tealium *library;
@property TEALConfiguration *configuration;

@end

@implementation TealiumAudienceStreamTests

- (void)setUp {
    [super setUp];
    
    self.library = [[Tealium alloc] initPrivate];
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    
    self.library = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

#pragma mark - Helpers

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
        
    //    if (!config) {
    //        config = self.configuration;
    //    }
    //
    //    __block BOOL isReady = NO;
    //
    //    self.library = [Tealium instanceWithConfiguration:<#(TEALConfiguration *)#>]
    //    [self.library setupConfiguration:config
    //                          completion:^(BOOL success, NSError *error) {
    //                              isReady = YES;
    //                          }];
    //    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
}

- (void) fetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    self.library.enabled = YES;
    
    __block BOOL isReady = NO;
    
    [self.library fetchSettings:settings completion:^(BOOL success, NSError *error) {
        
        isReady = YES;
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
}


#pragma mark - Trace

- (void) testTrace {
//    
//    [self enableLibraryWithConfiguration:nil];
//    
//    TEALRemoteSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//    
//    [self fetchRemoteSettingsWithSettings:settings];
//    
//    NSString *token = @"A1B2C3";
//    
//    settings = self.library.settingsStore.currentSettings;
//    
//    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource should default to nil");
//    
//    [self.library joinTraceWithToken:token];
//    
//    XCTAssertTrue([settings traceID] != nil, @"TraceID datasource:%@ now have a value.", [settings traceID]);
//    
//    XCTAssertTrue([[settings traceID] isEqualToString:token], @"TraceID datasource value: %@ should be same as token passed in: %@", settings.traceID, token);
//    
//    [self.library leaveTrace];
//    
//    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource :%@ should now be nil", [settings traceID]);
//    
}

//- (void) testConfigurationPollingFrequency {
//
//    TEALVisitorProfilePollingFrequency targetFrequency = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
//
//    // default
//    XCTAssertEqual(targetFrequency, self.configuration.pollingFrequency, @"TEALAudienceStreamConfiguration should default to %lu", (unsigned long)targetFrequency);
//
//    targetFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
//
//    self.configuration.pollingFrequency = targetFrequency;
//
//    TEALRemoteSettings *settings = [self.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//
//
//    XCTAssertEqual(targetFrequency, settings.pollingFrequency, @"Settigns Polling Frequency: %lu should be : %lu", (unsigned long)settings.pollingFrequency, (unsigned long)targetFrequency);
//
//
//    targetFrequency = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
//
//    self.configuration.pollingFrequency = targetFrequency;
//
//    settings = [self.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//
//    XCTAssertEqual(targetFrequency, settings.pollingFrequency, @"Settigns Polling Frequency: %lu should be : %lu", (unsigned long)settings.pollingFrequency, (unsigned long)targetFrequency);
//
//}

@end
