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


#pragma mark - ARCHIVING / UNARCHIVING TESTS

- (void) testArchiving {
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:@"testURLString"];
    
    [TEALPublishSettingsStore archivePublishSettings:settings];
    
    TEALPublishSettings *unarchivedSettings = [TEALPublishSettingsStore unarchivePublishSettingsForInstanceID:settings.url];
    
    XCTAssertTrue([settings isEqual:unarchivedSettings], @"Problem archiving / unarchiving test publish settings");

}

@end
