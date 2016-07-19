//
//  TealiumTagManagementTests.m
//  TealiumTagManagementTests
//
//  Created by Jason Koo on 5/31/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tealium+PrivateHeader.h"
#import "TEALTagDispatchService.h"

@interface TealiumTagManagementTests : XCTestCase

@end

@implementation TealiumTagManagementTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - CLASS TESTS

- (void) testTealDispatchesReady {
    
    // Create mock'sh dispatch services for testing
    TEALTagDispatchService *tmServiceOk = [[TEALTagDispatchService alloc] initWithPublishURLString:@"ok"
                                                                                operationManager:nil];
    [tmServiceOk setStatus:TEALDispatchNetworkServiceStatusReady];
    
    TEALTagDispatchService *tmServiceNotReady = [[TEALTagDispatchService alloc] initWithPublishURLString:@"notReady"
                                                                                        operationManager:nil];
    [tmServiceNotReady setStatus:TEALDispatchNetworkServiceStatusUnknown];
    
    
    
    // All Ready
    NSMutableArray<TEALDispatchService> *allReadyArray = [NSMutableArray<TEALDispatchService> array];
    [allReadyArray addObject:tmServiceOk];
    [allReadyArray addObject:tmServiceOk];
    
    // One not ready
    NSMutableArray<TEALDispatchService> *oneNotReadyArray = [NSMutableArray<TEALDispatchService> array];
    [oneNotReadyArray addObject:tmServiceOk];
    [oneNotReadyArray addObject:tmServiceNotReady];
    
    // All not ready
    NSMutableArray<TEALDispatchService> *allNotReadyArray = [NSMutableArray<TEALDispatchService> array];
    [allNotReadyArray addObject:tmServiceNotReady];
    [allNotReadyArray addObject:tmServiceNotReady];
    
    XCTAssertTrue([Tealium dispatchServicesReady:allReadyArray]);
    XCTAssertFalse([Tealium dispatchServicesReady:oneNotReadyArray]);
    XCTAssertFalse([Tealium dispatchServicesReady:allNotReadyArray]);

}

@end
