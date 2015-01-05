//
//  MAVEABPermissionPromptHandlerTest.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/31/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEABTestDataFactory.h"


@interface MAVEABPermissionPromptHandlerTest : XCTestCase

@end

@implementation MAVEABPermissionPromptHandlerTest

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPromptForContactsWhenDoublePromptYes; {
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc]
        initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    XCTAssertTrue(remoteConfig.enableContactsPrePrompt);

    MAVEABPermissionPromptHandler *permissionPrompter = [[MAVEABPermissionPromptHandler alloc] init];
    
    // whole prompt method is wrapped in a block waiting on remote configuration
    // so we have to use mock check block to actually call the code we'll test
    id mock = OCMPartialMock([MaveSDK sharedInstance].remoteConfigurationBuilder);
    OCMStub([mock initializeObjectWithTimeout:2.0 completionBlock:
             [OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(id) = obj;
        completionBlock(remoteConfig);
        return YES;
    }]]);

    // Mock expected behavior
    id permissionPrompterMock = OCMPartialMock(permissionPrompter);

    OCMExpect([permissionPrompterMock
               showPrePromptAlertWithTitle:remoteConfig.contactsPrePromptTemplate.title
               message:remoteConfig.contactsPrePromptTemplate.message
               cancelButtonCopy:remoteConfig.contactsPrePromptTemplate.cancelButtonCopy
               acceptbuttonCopy:remoteConfig.contactsPrePromptTemplate.acceptButtonCopy]);

    OCMExpect([permissionPrompterMock
               logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionPromptView]);

    // Run the method under test
    [permissionPrompter promptForContactsWithCompletionBlock:nil];

    OCMVerifyAll(permissionPrompterMock);
}

- (void)testPromptForContactsWhenDoublePromptNo {
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.enableContactsPrePrompt = 0;

    // Since method under test is in a block, this wrapper calls the block to test the code
    id buildConfigMock = OCMPartialMock([MaveSDK sharedInstance].remoteConfigurationBuilder);
    OCMStub([buildConfigMock initializeObjectWithTimeout:2.0 completionBlock:
             [OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(id) = obj;
        completionBlock(remoteConfig);
        return YES;
    }]]);

    // Object under test, set up expectaions
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    id promptHandlerMock = OCMPartialMock(promptHandler);
    OCMExpect([promptHandlerMock loadAddressBookAndComplete]);
    OCMExpect([promptHandlerMock
               logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionPromptView]);

    // Code under test
    MAVEABDataBlock completionBlock = ^void(NSDictionary *data){};
    [promptHandler promptForContactsWithCompletionBlock:completionBlock];

    OCMVerifyAll(promptHandlerMock);
    XCTAssertEqualObjects(promptHandler.prePromptTemplate, remoteConfig.contactsPrePromptTemplate);
    XCTAssertEqual(promptHandler.completionBlock, completionBlock);
}

- (void)testPrePromptPermissionDenied {
    // Test the alert view delegate method with the "No Thanks" button pressed (index 0)
    // Should call the completion block with nil
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    __block NSDictionary *returnedData;
    __block BOOL called = NO;
    promptHandler.completionBlock = ^void(NSDictionary *indexedData) {
        called = YES;
        returnedData = indexedData;
    };

    id mock = OCMPartialMock(promptHandler);
    OCMExpect([mock logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionDenied]);

    [promptHandler alertView:nil clickedButtonAtIndex:0];

    OCMVerifyAll(mock);
    XCTAssertTrue(called);
    XCTAssertNil(returnedData);
}

- (void)testPrePromptPermissionGranted {
    // Test alert view delegate method when permission granted
    // Should call the underlying method to load the address book
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    id mock = OCMPartialMock(promptHandler);

    OCMExpect([mock logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionGranted]);
    OCMExpect([mock loadAddressBookAndComplete]);

    [promptHandler alertView:nil clickedButtonAtIndex:1];

    OCMVerifyAll(mock);
}

- (void)testCompleteAfterPermissionGranted {
    NSArray *fakeContacts = @[[MAVEABTestDataFactory personWithFirstName:@"Foo" lastName:@"Cosson"]];
    NSDictionary *expectedIndexedData = [MAVEABUtils indexedDictionaryFromMAVEABPersonArray:fakeContacts];

    // generate object under test and its block
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    __block NSDictionary *returnedData;
    promptHandler.completionBlock = ^void(NSDictionary *data) {
        returnedData = data;
    };

    id mock = OCMPartialMock(promptHandler);
    OCMExpect([mock logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionGranted]);

    [promptHandler completeAfterPermissionGranted:fakeContacts];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(returnedData, expectedIndexedData);
}

- (void)testCompleteAfterPermissionDenied {
    // generate object under test and its block
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    __block NSDictionary *returnedData;
    __block BOOL called;
    promptHandler.completionBlock = ^void(NSDictionary *data) {
        called = YES;
        returnedData = data;
    };

    id mock = OCMPartialMock(promptHandler);
    OCMExpect([mock logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionDenied]);

    [promptHandler completeAfterPermissionDenied];

    OCMVerifyAll(mock);
    XCTAssertTrue(called);
    XCTAssertNil(returnedData);
}

- (void)testLogContactsPromptRelatedEventWithRoute {
    NSString *fakeRoute = @"aasdk023radfnailwrf";
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    promptHandler.prePromptTemplate =
        [[MAVERemoteConfigurationContactsPrePromptTemplate alloc]initWithDictionary:
        [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData]];
    XCTAssertNotNil(promptHandler.prePromptTemplate.templateID);
    id APIInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);

    NSDictionary *expectedParams = @{MAVEAPIParamPrePromptTemplateID:
                                         promptHandler.prePromptTemplate.templateID};
    OCMExpect([APIInterfaceMock trackGenericUserEventWithRoute:fakeRoute
                                              additionalParams:expectedParams]);

    [promptHandler logContactsPromptRelatedEventWithRoute:fakeRoute];

    OCMVerifyAll(APIInterfaceMock);
}

@end
