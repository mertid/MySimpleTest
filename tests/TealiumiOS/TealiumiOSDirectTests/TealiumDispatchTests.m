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

NSString * const TEAL_DISPATCH_TEST_INSTANCE_ID = @"testInstance";

@implementation TealiumDispatchTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    self.library = nil;
    [super tearDown];
}


#pragma mark - Helpers

- (TEALConfiguration *) liveConfig {
    
    return [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                               profile:@"demo"
                                           environment:@"dev"];
}

- (TEALConfiguration *) nonExistentConfig {
    
    return [TEALConfiguration configurationWithAccount:@"what"
                                               profile:@"who"
                                           environment:@"wow"];
    
}

- (void) useLiveLibraryInstance {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];

    self.library = [Tealium newInstanceForKey:TEAL_DISPATCH_TEST_INSTANCE_ID
                                configuration:[self liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       [expectation fulfill];
                                       
                                   }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void) testFetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
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
    
    [self useLiveLibraryInstance];

    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        if (error){
            NSLog(@"%s error:%@", __FUNCTION__, error);
        }
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);

    };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                                withPayload:@{@"test_key":@"test_value"}];
    
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];
    
    
}

- (void) testViewDispatch {
    
    [self useLiveLibraryInstance];
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        if (error){
            NSLog(@"%s error:%@", __FUNCTION__, error);
        }
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
        
    };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeView
                                               withPayload:@{@"test_key":@"test_value"}];
    
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];
    
    
}

@end
