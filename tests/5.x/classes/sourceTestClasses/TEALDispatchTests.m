//
//  TealiumDispatchTests.m
//  TealiumTests
//
//  Created by Jason Koo on 7/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings.h"
#import "TEALDispatch+PrivateHeader.h"

@interface TealiumDispatchTests : XCTestCase

@property (strong) Tealium *library;
@property TEALConfiguration *configuration;

@end


@implementation TealiumDispatchTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    self.library = nil;
    [super tearDown];
}


#pragma mark - Helpers

- (void) useLiveLibraryInstance {
    
    __block BOOL isReady = NO;

    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       isReady = YES;
                                       
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
}

- (void) testFetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    [self useLiveLibraryInstance];
    
    XCTestExpectation *finishedFetching = [self expectationWithDescription:@"finishFetching"];
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        [finishedFetching fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
}


#pragma mark - Dispatch

- (void) testEventDispatch {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
        
        
        isReady = YES;
        
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        if (error){
            NSLog(@"%s error:%@", __FUNCTION__, error);
        }
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);

    };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                                withPayload:@{@"test_key":@"test_value"}];
    
    [self measureBlock:^{
        
    
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];
    
    }];
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
