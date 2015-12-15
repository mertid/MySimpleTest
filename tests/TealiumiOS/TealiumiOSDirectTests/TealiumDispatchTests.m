//
//  TealiumDispatchTests.m
//  TealiumTests
//
//  Created by Jason Koo on 7/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Tealium+PrivateTestHeader.h"
#import "TEALSettings.h"
#import "TEALDispatch+PrivateHeader.h"

@interface TealiumDispatchTests : XCTestCase

@property (strong) Tealium *library;
@property TEALConfiguration *configuration;

@end

@implementation TealiumDispatchTests

- (void)setUp {
    [super setUp];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setup"];
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    
    self.library = [Tealium  newInstanceForKey:@"testInstance" configuration:self.configuration completion:^(BOOL success, NSError * _Nullable error) {
        
        if (success){
            [expectation fulfill];
        }
        
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)tearDown {
    
    self.library = nil;
    [super tearDown];
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

#pragma mark - Helpers

//- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
//    
//    if (!config) {
//        config = self.configuration;
//    }
//
//    XCTestExpectation *finishedLoadingExpectation = [self expectationWithDescription:@"finishLoading"];
//    
//    self.library = [Tealium newInstanceForKey:@"test" configuration:config];
//    [self.library instanceWithConfiguration:config
//                          completion:^(BOOL success, NSError *error) {
//                              [finishedLoadingExpectation fulfill];
//                          }];
//    
//    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
//            NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//}

- (void) tesetFetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    self.library.enabled = YES;
    
    XCTestExpectation *finishedFetching = [self expectationWithDescription:@"finishFetching"];
    
    [self.library fetchSettings:settings completion:^(BOOL success, NSError *error) {
        [finishedFetching fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
}


#pragma mark - Dispatch

- (void) testEventDispatch {
    
    XCTestExpectation *finished = [self expectationWithDescription:@"finishedEventDispatch"];

    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
        [finished fulfill];
        
    };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                                withPayload:@{@"test_key":@"test_value"}];
    
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];
    
    
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
    
}

//- (void) testEventDispatchDataSources {
//    [self enableLibraryWithConfiguration:nil];
//    
//    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
//        
//        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
//    };
//    
//    TEALDispatch *dispatch = [TEALDispatch dispatchForEvent:TEALEventTypeLink
//                                                withPayload:nil];
//    [self.library.dispatchManager addDispatch:dispatch
//                              completionBlock:completion];
//    
//    
//    XCTestExpectation *finished = [self expectationWithDescription:@"finished"];
//    
//    completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
//        [finished fulfill];
//        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
//    };
//    
//    
//    [self.library.dispatchManager addDispatch:dispatch
//                              completionBlock:completion];
//    
//    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
//        NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//}

//- (void) testEventDispatchQueued {
//    [self enableLibraryWithConfiguration:nil];
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

- (void) testViewDispatch {
    
    
    XCTestExpectation *finished = [self expectationWithDescription:@"finishedViewDispatch"];

    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
        [finished fulfill];
    };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeView
                                                withPayload:@{@"test_key":@"test_value"}];
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];
    
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
    
}

@end
