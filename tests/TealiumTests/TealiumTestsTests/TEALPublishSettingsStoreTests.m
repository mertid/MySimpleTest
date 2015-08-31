//
//  TEALSettingsStoreTests.m
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <Tealium/TEALPublishSettings.h>
#import <Tealium/TEALPublishSettingsStore.h>
#import <Tealium/TEALOperationManager.h>
#import <Tealium/TEALURLSessionManager.h>
#import <Tealium/TEALConfiguration.h>

@interface TEALPublishSettingsStoreTests : XCTestCase

@property (nonatomic, strong) TEALPublishSettingsStore *store;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;

@property (nonatomic, strong) TEALConfiguration *configuration;

@end

@implementation TEALPublishSettingsStoreTests

- (void)setUp {
    [super setUp];
    
    self.operationManager = [TEALOperationManager new];
    
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

#pragma mark - INITIALIZATION TESTS

- (void) testInitializeWithInstanceID {
    
    NSString *instanceID = @"testInstance";
    
    self.store = [[TEALPublishSettingsStore alloc] initWithInstanceID:instanceID];
    
    XCTAssertTrue(self.store, @"Publish Settings Store did not initialize as expected.");

    XCTAssertTrue([[self.store instanceIDCopy] isEqualToString:instanceID], @"Publish Settings Store did not retain expected instanceID:%@", [self.store instanceIDCopy]);
}

- (void) testInitializeWithMissingInstanceID {
    self.store = [[TEALPublishSettingsStore alloc] initWithInstanceID:nil];
    
    XCTAssertFalse(self.store, @"Publish Settings Store initialized unexpectedly.");
}

- (void) testInitializeWithBlankInstanceID {
    self.store = [[TEALPublishSettingsStore alloc] initWithInstanceID:@"   "];
    
    XCTAssertFalse(self.store, @"Publish Settings Store initialized unexpectedly.");
}

#pragma mark - ARCHIVING / UNARCHIVING TESTS

- (void) testArchiving {
    
    self.store = [[TEALPublishSettingsStore alloc] initWithInstanceID:@"test"];
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:@"testURLString"];
    
    [self.store archivePublishSettings:settings];
    
    TEALPublishSettings *unarchivedSettings = [self.store unarchivePublishSettings];
    
    XCTAssertTrue([settings isEqual:unarchivedSettings], @"Problem archiving / unarchiving test publish settings");

}

@end
