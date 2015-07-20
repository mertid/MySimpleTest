//
//  TealiumCollectTests.m
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <Tealium/Tealium.h>
#import <Tealium/TEALSettings.h>
#import "Tealium+PrivateHeader.h"
#import <Tealium/TEALDispatch.h>

@interface TealiumTests : XCTestCase

@property (strong) Tealium *library;
@property TEALConfiguration *configuration;

@end

@implementation TealiumTests

- (void) setUp {
    [super setUp];
    
    self.library = [[Tealium alloc] initPrivate];
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
}

- (void) tearDown {
    
    [[Tealium sharedInstance] disable];
    self.library = nil;
    
    [super tearDown];
}

#pragma mark - Helpers

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    
    // TODO: Hook up to use protocol
    
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

#pragma mark - Test Configuration / Settings updates

- (void) testSettingsStorage {
    
    [self enableLibraryWithConfiguration:nil];
    
    TEALSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration
                                                                         visitorID:@""];
    
    [self fetchRemoteSettingsWithSettings:settings];
    
    XCTAssertTrue([self.library.settingsStore.currentSettings isEqual:settings], @"saved settings should be same object passed in");
}

- (void) testInvalidAccount {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"invalid_tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    [self enableLibraryWithConfiguration:config];
    
    TEALSettings *settings = [self.library.settingsStore settingsFromConfiguration:config visitorID:@""];
    
    [self fetchRemoteSettingsWithSettings:settings];
    
    XCTAssertTrue(self.library.settingsStore.currentSettings.status == TEALSettingsStatusInvalid, @"Stored status should be invalid");
    
    XCTAssertFalse(self.library.enabled, @"Library should be disabled on invalid settings status");
}

- (void) testNoMobilePublishSettings {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"ios-demo"
                                                                environment:@"dev"];
    
    [self enableLibraryWithConfiguration:config];
    
    TEALSettings *settings = [self.library.settingsStore settingsFromConfiguration:config visitorID:@""];
    
    [self fetchRemoteSettingsWithSettings:settings];
    
    XCTAssertTrue(self.library.settingsStore.currentSettings.status == TEALSettingsStatusInvalid, @"Stored status should be invalid");
    
    XCTAssertFalse(self.library.enabled, @"Library should be disabled on invalid settings status");
}

#pragma mark - Trace

- (void) testTrace {
    
    [self enableLibraryWithConfiguration:nil];

    TEALSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
    
    [self fetchRemoteSettingsWithSettings:settings];
    
    NSString *token = @"A1B2C3";
    
    settings = self.library.settingsStore.currentSettings;
    
    XCTAssertTrue(settings.traceID == nil, @"TraceID datasource should default to nil");
    
    [self.library joinTraceWithToken:token];
    
    XCTAssertTrue(settings.traceID != nil, @"TraceID datasource:%@ now have a value.", settings.traceID);
    
    XCTAssertTrue([settings.traceID isEqualToString:token], @"TraceID datasource value: %@ should be same as token passed in: %@", settings.traceID, token);
    
    [self.library leaveTrace];
    
    XCTAssertTrue(settings.traceID == nil, @"TraceID datasource :%@ should now be nil", settings.traceID);
    
}


#pragma mark - Dispatch

- (void) testDispatch {
    
    [self enableLibraryWithConfiguration:nil];
    
    TEALSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
    
    [self fetchRemoteSettingsWithSettings:settings];
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
    };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeLink
                                                withPayload:@{@"test_key":@"test_value"}];
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];

    self.library.settingsStore.currentSettings.dispatchSize = 5;
    
    completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        XCTAssertEqual(status, TEALDispatchStatusQueued, @"Dispatch: %@, should have been queued", dispatch);
    };
    
    for (NSInteger xi = 0; xi < 5; xi ++) {
        
        TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeLink
                                                    withPayload:@{@"test_key":@"test_value"}];
        [self.library.dispatchManager addDispatch:dispatch
                                  completionBlock:completion];
    }
}



@end
