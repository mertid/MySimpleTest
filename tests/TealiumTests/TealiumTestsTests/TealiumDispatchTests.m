//
//  TealiumDispatchTests.m
//  TealiumTests
//
//  Created by Jason Koo on 7/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <Tealium/Tealium.h>
#import <Tealium/TEALSettings.h>
#import "Tealium+PrivateHeader.h"
#import <Tealium/TEALDispatch.h>

@interface TealiumDispatchTests : XCTestCase

@property (strong) Tealium *library;
@property TEALConfiguration *configuration;

@end

@implementation TealiumDispatchTests

- (void)setUp {
    [super setUp];
    
    self.library = [[Tealium alloc] initPrivate];
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
}

- (void)tearDown {
    
    [[Tealium sharedInstance] disable];
    self.library = nil;
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


#pragma mark - Dispatch

//- (void) testEventDispatch {
//    
//    [self enableLibraryWithConfiguration:nil];
//    
//    TEALRemoteSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//    
//    [self fetchRemoteSettingsWithSettings:settings];
//    
//    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
//        
//        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
//    };
//    
//    TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeLink
//                                                withPayload:@{@"test_key":@"test_value"}];
//    [self.library.dispatchManager addDispatch:dispatch
//                              completionBlock:completion];
//    
//    self.library.settingsStore.currentSettings.dispatchSize = 5;
//    
//    completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
//        
//        XCTAssertEqual(status, TEALDispatchStatusQueued, @"Dispatch: %@, should have been queued", dispatch);
//    };
//    
//    for (NSInteger xi = 0; xi < 5; xi ++) {
//        
//        TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeLink
//                                                    withPayload:@{@"test_key":@"test_value"}];
//        [self.library.dispatchManager addDispatch:dispatch
//                                  completionBlock:completion];
//    }
//}
//
//
//- (void) testViewDispatch {
//    
//    [self enableLibraryWithConfiguration:nil];
//    
//    TEALRemoteSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//    
//    [self fetchRemoteSettingsWithSettings:settings];
//    
//    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
//        
//        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
//    };
//    
//    TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeView
//                                                withPayload:@{@"test_key":@"test_value"}];
//    [self.library.dispatchManager addDispatch:dispatch
//                              completionBlock:completion];
//    
//    self.library.settingsStore.currentSettings.dispatchSize = 5;
//    
//    completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
//        
//        XCTAssertEqual(status, TEALDispatchStatusQueued, @"Dispatch: %@, should have been queued", dispatch);
//    };
//    
//    for (NSInteger xi = 0; xi < 5; xi ++) {
//        
//        TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeLink
//                                                    withPayload:@{@"test_key":@"test_value"}];
//        [self.library.dispatchManager addDispatch:dispatch
//                                  completionBlock:completion];
//    }
//}

@end
