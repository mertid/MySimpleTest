//
//  TEALSettingsStoreTests.m
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TEALPublishSettings.h"
#import "TEALPublishSettingsStore.h"
#import "TEALOperationManager.h"
#import "TEALURLSessionManager.h"
#import "TEALConfiguration.h"

@interface TEALPublishSettingsStoreTests : XCTestCase

@property (nonatomic, strong) TEALPublishSettingsStore *store;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;

@property (nonatomic, strong) TEALConfiguration *configuration;

@end

NSString * const TEAL_INSTANCE_ID = @"test";

@implementation TEALPublishSettingsStoreTests

- (void)setUp {
    [super setUp];
    
    self.operationManager = [[TEALOperationManager alloc] initWithInstanceID:TEAL_INSTANCE_ID];
    
    self.urlSessionManager = [[TEALURLSessionManager alloc] initWithConfiguration:nil];
    
    self.urlSessionManager.completionQueue = self.operationManager.underlyingQueue;
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
}

- (void)tearDown {
    
    self.operationManager = nil;
    self.urlSessionManager = nil;
    self.store = nil;
    self.configuration = nil;
    
    [super tearDown];
}


#pragma mark - ARCHIVING / UNARCHIVING TESTS

- (void) testArchiving {
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:TEAL_INSTANCE_ID];
    
    [TEALPublishSettingsStore archivePublishSettings:settings];
    
    TEALPublishSettings *unarchivedSettings = [TEALPublishSettingsStore unarchivePublishSettingsForInstanceID:TEAL_INSTANCE_ID];
    
    XCTAssertTrue([settings isEqualToPublishSettings:unarchivedSettings], @"Problem archiving / unarchiving test publish settings - initial:%@ unarchived:%@", settings, unarchivedSettings);

}

@end
