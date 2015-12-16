//
//  TEALWKExtensionTests.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/16/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TEALWKExtension+PrivateHeader.h"
#import "TEALDataSourceConstants.h"

@interface TEALWKExtensionTests : XCTestCase

@property TEALWKExtension *extension;

@end

NSString * const TEAL_INSTANCE_ID = @"1";

@implementation TEALWKExtensionTests


- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {

    
    self.extension = nil;
    
    [super tearDown];
}

#pragma mark - OPTIONS
                      
- (TEALWKExtensionConfiguration *) defaultConfig {

    return [TEALWKExtensionConfiguration configuration];
    
}

- (TEALWKExtensionConfiguration *) configWithDevLogs {
    
    TEALWKExtensionConfiguration * config = [TEALWKExtensionConfiguration configuration];
    
    [config setLogLevel:TEALLogLevelDev];
    
    return config;
}

- (TEALWKExtensionConfiguration *) configWithNoOfflineQueue {
    
    TEALWKExtensionConfiguration * config = [TEALWKExtensionConfiguration configuration];
    
    [config setLogLevel:TEALLogLevelDev];
    
    [config setOfflineDispatchQueueSize:0];
    
    return config;
}

- (TEALWKExtensionConfiguration *) configWithSmallOfflineQueue {
    
    TEALWKExtensionConfiguration * config = [TEALWKExtensionConfiguration configuration];
    
    [config setLogLevel:TEALLogLevelDev];
    
    [config setOfflineDispatchQueueSize:1];
    
    return config;
}

- (void) defaultInit {
    
    // Will test init when called

    XCTestExpectation *expectation = [self expectationWithDescription:@"testInit"];
    
    self.extension = [TEALWKExtension newInstanceForKey:TEAL_INSTANCE_ID
                                          configuration:[self defaultConfig]
                                             completion:^(BOOL success, NSError * _Nullable error) {
                                                
                                                 [expectation fulfill];
                                                 
                                                     NSLog(@"%s Error: %@", __FUNCTION__, error);
                                             }];
    
    
    XCTAssert(self.extension, @"Extension failed to start with a valid configuration.");
}

#pragma mark - TESTS

/*
 
 Cannot test actually delivery do to test limitations - test queuing only
 
 */

- (void) testEventQueueCall {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testEventHandOff"];
    
    NSString *testTitle = @"testEvent";
    
    [self defaultInit];
    
    [self.extension trackEventWithTitle:testTitle
                            dataSources:nil
                             completion:^(BOOL success, NSError * _Nullable error) {
                                 
                                 
                                 [expectation fulfill];
                                 
                                     NSLog(@"%s error:%@", __FUNCTION__, error);
                             }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    // We're expecting this call to queue as the test environment should not be
    // WC Session compliant
    
    NSArray *queueObjects = [self.extension.queue allQueuedObjects];
    
    NSDictionary *queuedCall = [queueObjects lastObject];
    
    NSDictionary *queuedCallPayload = queuedCall[TEALWKCommandTrackKey];
    
    XCTAssert([queuedCallPayload isKindOfClass:[NSDictionary class]], @"Last queued object not of dictionary type: %@", queuedCall);
    
    NSString *title = queuedCallPayload[TEALWKCommandTrackArgumentTitleKey];
    
    XCTAssert([testTitle isEqualToString:title], @"Queue call title: %@ - did not match test title.", title);
    
    
}

- (void) testViewQueueCall {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testViewHandOff"];
    
    NSString *testTitle = @"testView";
    
    [self defaultInit];
    
    [self.extension trackViewWithTitle:testTitle
                            dataSources:nil
                             completion:^(BOOL success, NSError * _Nullable error) {
                                 
                                 [expectation fulfill];
                                 
                                 NSLog(@"%s error:%@", __FUNCTION__, error);
                             }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    // We're expecting this call to queue as the test environment should not be
    // WC Session compliant
    
    NSArray *queueObjects = [self.extension.queue allQueuedObjects];
    
    NSDictionary *queuedCall = [queueObjects lastObject];
    
    NSDictionary *queuedCallPayload = queuedCall[TEALWKCommandTrackKey];
    
    XCTAssert([queuedCallPayload isKindOfClass:[NSDictionary class]], @"Last queued object not of dictionary type: %@", queuedCall);
    
    NSString *title = queuedCallPayload[TEALWKCommandTrackArgumentTitleKey];
    
    XCTAssert([testTitle isEqualToString:title], @"Queue call title: %@ - did not match test title.", title);
    
    
}

- (void) testDestory {
    
    [self defaultInit];
    
    // Warning, the destory all goes in the operation queue whereas the init does not.
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [self.extension destroy];

    
    TEALWKExtension *extension = [TEALWKExtension instanceForKey:TEAL_INSTANCE_ID];
    
    XCTAssert(!extension, @"Extension instance was not destroyed");
}

@end
