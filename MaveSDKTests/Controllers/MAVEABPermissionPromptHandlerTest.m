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

///
/// Test prompt function when status is already granted or denied
///
- (void)testPromptForContactsWhenPermissionDenied {
    // Stub status
    id utilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([utilsMock addressBookPermissionStatus])
        .andReturn(MAVEABPermissionStatusDenied);

    id mock = OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([mock alloc]).andReturn(mock);
    OCMExpect([mock initCustom]).andReturn(mock);

    OCMExpect([mock completeAfterPermissionDenied]);

    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:
        ^(NSDictionary *indexedContacts) {}];

    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testPromptForContactsWhenPermissionGranted {
    // Stub status
    id utilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([utilsMock addressBookPermissionStatus])
        .andReturn(MAVEABPermissionStatusAllowed);

    id mock = OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([mock alloc]).andReturn(mock);
    OCMExpect([mock initCustom]).andReturn(mock);

    OCMExpect([mock loadAddressBookAndComplete]);

    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:^(NSDictionary *indexedContacts) {}];

    OCMVerifyAll(mock);
}

///
/// Test prompt function when status is unprompted
///
- (void)testPromptForContactsWhenDoublePromptYes; {
    // Stub to make it look like we haven't prompted user yet
    id utilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([utilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);

    id permissionPrompterMock =
        OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([permissionPrompterMock alloc]).andReturn(permissionPrompterMock);
    OCMExpect([permissionPrompterMock initCustom]).andReturn(permissionPrompterMock);

    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc]
        initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    XCTAssertTrue(remoteConfig.contactsPrePrompt.enabled);

    // whole prompt method is wrapped in a block waiting on remote configuration
    // so we have to use mock check block to actually call the code we'll test
    id configBuilderMock = OCMPartialMock([MaveSDK sharedInstance].remoteConfigurationBuilder);
    OCMStub([configBuilderMock createObjectWithTimeout:1.0 completionBlock:
             [OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(id) = obj;
        completionBlock(remoteConfig);
        return YES;
    }]]);

    OCMExpect([permissionPrompterMock
               showPrePromptAlertWithTitle:remoteConfig.contactsPrePrompt.title
               message:remoteConfig.contactsPrePrompt.message
               cancelButtonCopy:remoteConfig.contactsPrePrompt.cancelButtonCopy
               acceptbuttonCopy:remoteConfig.contactsPrePrompt.acceptButtonCopy]);

    OCMExpect([permissionPrompterMock
               logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionPromptView]);

    // Run the method under test
    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:nil];

    OCMVerifyAll(permissionPrompterMock);
}

- (void)testPromptForContactsWhenDoublePromptNo {
    // Stub to make it look like we haven't prompted user yet
    id utilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([utilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);

    id permissionPrompterMock =
    OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([permissionPrompterMock alloc]).andReturn(permissionPrompterMock);
    OCMExpect([permissionPrompterMock initCustom]).andReturn(permissionPrompterMock);

    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.contactsPrePrompt.enabled = 0;

    // Since method under test is in a block, this wrapper calls the block to test the code
    id buildConfigMock = OCMPartialMock([MaveSDK sharedInstance].remoteConfigurationBuilder);
    OCMStub([buildConfigMock createObjectWithTimeout:2.0 completionBlock:
             [OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(id) = obj;
        completionBlock(remoteConfig);
        return YES;
    }]]);

    MAVEABDataBlock completionBlock = ^void(NSDictionary *data){};

    // set up expectaions
    OCMExpect([permissionPrompterMock loadAddressBookAndComplete]);
    OCMExpect([permissionPrompterMock
               logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionPromptView]);
    OCMExpect([permissionPrompterMock setCompletionBlock:(id)completionBlock]);
    OCMExpect([permissionPrompterMock setPrePromptTemplate:remoteConfig.contactsPrePrompt]);

    // Code under test

    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:completionBlock];

    OCMVerifyAll(permissionPrompterMock);
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
        [[MAVERemoteConfigurationContactsPrePrompt alloc]initWithDictionary:
        [MAVERemoteConfigurationContactsPrePrompt defaultJSONData]];
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
