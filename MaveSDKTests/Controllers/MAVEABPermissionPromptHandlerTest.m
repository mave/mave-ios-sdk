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
#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEABTestDataFactory.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

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

    [[mock reject] setBeganFlowAsStatusUnprompted:YES];

    OCMExpect([mock completeAfterPermissionDenied]);

    MAVEABPermissionPromptHandler *handler = [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:
        ^(NSArray *indexedContacts) {}];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(handler, mock);
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

    [[mock reject] setBeganFlowAsStatusUnprompted:YES];

    OCMExpect([mock loadAddressBookAndComplete]);

    MAVEABPermissionPromptHandler *handler = [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:^(NSArray *indexedContacts) {}];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(handler, mock);
    [mock stopMocking];
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

    __block MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc]
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

    OCMExpect([permissionPrompterMock setBeganFlowAsStatusUnprompted:YES]);

    OCMExpect([permissionPrompterMock
               showPrePromptAlertWithTitle:remoteConfig.contactsPrePrompt.title
               message:remoteConfig.contactsPrePrompt.message
               cancelButtonCopy:remoteConfig.contactsPrePrompt.cancelButtonCopy
               acceptbuttonCopy:remoteConfig.contactsPrePrompt.acceptButtonCopy]);

    OCMExpect([permissionPrompterMock
               logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionPromptView]);

    // Run the method under test
    MAVEABPermissionPromptHandler *handler = [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock:nil];

    OCMVerifyAll(permissionPrompterMock);
    XCTAssertEqualObjects(handler, permissionPrompterMock);
    [permissionPrompterMock stopMocking];
}

- (void)testPromptForContactsWhenDoublePromptNo {
    // Stub to make it look like we haven't prompted user yet
    id utilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([utilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);

    id permissionPrompterMock = OCMClassMock([MAVEABPermissionPromptHandler class]);
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

    MAVEABDataBlock completionBlock = ^void(NSArray *data){};

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
    __block NSArray *returnedData;
    __block BOOL called = NO;
    promptHandler.completionBlock = ^void(NSArray *indexedData) {
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

- (void)testCompleteAfterPermissionUnfulfilledToGranted {
    NSArray *fakeContacts = @[[MAVEABTestDataFactory personWithFirstName:@"Foo" lastName:@"Cosson"]];

    // generate object under test and its block
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    __block NSArray *returnedData;
    promptHandler.completionBlock = ^void(NSArray *data) {
        returnedData = data;
    };

    // Mock the contact sync background job and ensure it runs when this is called
    id abSyncerMock = OCMPartialMock([MaveSDK sharedInstance].addressBookSyncManager);
    OCMExpect([abSyncerMock syncContactsAndPopulateSuggestedInBackground:fakeContacts]);

    // If had status unfulfilled to start with, it should log event
    promptHandler.beganFlowAsStatusUnprompted = YES;
    id mock = OCMPartialMock(promptHandler);
    OCMExpect([mock logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionGranted]);

    [promptHandler completeAfterPermissionGranted:fakeContacts];


    OCMVerifyAll(mock);
    OCMVerifyAll(abSyncerMock);
    XCTAssertEqualObjects(returnedData, fakeContacts);
}

- (void)testCompleteAfterPermissionAlreadyGranted {
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    promptHandler.completionBlock = ^(NSArray *dict) {};

    // If already had status granted to start with, don't log permission
    // granted event (or any other event)
    promptHandler.beganFlowAsStatusUnprompted = NO;
    id mock = OCMPartialMock(promptHandler);
    [[mock reject] logContactsPromptRelatedEventWithRoute:[OCMArg any]];

    [promptHandler completeAfterPermissionGranted:nil];

    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testCompleteAfterPermissionDeniedCallsBlock {
    // generate object under test and its block
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    __block NSArray *returnedData;
    __block BOOL called;
    promptHandler.completionBlock = ^void(NSArray *data) {
        called = YES;
        returnedData = data;
    };
    // If had status unfulfilled to start with, it should log event
    promptHandler.beganFlowAsStatusUnprompted = YES;
    id mock = OCMPartialMock(promptHandler);
    OCMExpect([mock logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionDenied]);

    [promptHandler completeAfterPermissionDenied];

    OCMVerifyAll(mock);
    XCTAssertTrue(called);
    XCTAssertNil(returnedData);
}

- (void)testCompleteAfterPermissionAlreadyDenied {
    MAVEABPermissionPromptHandler *promptHandler = [[MAVEABPermissionPromptHandler alloc] init];
    promptHandler.completionBlock = ^(NSArray *dict) {};

    // If already had status granted to start with, don't log permission
    // granted event (or any other event)
    promptHandler.beganFlowAsStatusUnprompted = NO;
    id mock = OCMPartialMock(promptHandler);
    [[mock reject] logContactsPromptRelatedEventWithRoute:[OCMArg any]];

    [promptHandler completeAfterPermissionDenied];

    OCMVerifyAll(mock);
    [mock stopMocking];
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
                                              additionalParams:expectedParams
                                               completionBlock:nil]);

    [promptHandler logContactsPromptRelatedEventWithRoute:fakeRoute];

    OCMVerifyAll(APIInterfaceMock);
}

- (void)testLoadAddressBookSynchronouslyIfPermissionGrantedWhenPermissionNotGranted {
    id abUtilsMock = OCMClassMock([MAVEABUtils class]);
    OCMExpect([abUtilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);

    NSArray *contacts = [MAVEABPermissionPromptHandler loadAddressBookSynchronouslyIfPermissionGranted];
    XCTAssertNil(contacts);
    OCMVerifyAll(abUtilsMock);
}

- (void)testLoadAddressBookSynchronouslyIfPermissionGranted {
    NSString *status = [MAVEABUtils addressBookPermissionStatus];
    // TODO: Add suites of tests to run with and without address book permissions, and build scripts that
    // set the simulator permissions accordingly and run tests in all the states.  For now, don't fail
    // when no permissions but only run this test when we have permissions
    if ([status isEqualToString:MAVEABPermissionStatusAllowed]) {
        MAVEInfoLog(@"Address book permission granted, actually running test testLoadAddressBookSynchronouslyIfPermissionGranted");
        NSArray *contacts = [MAVEABPermissionPromptHandler loadAddressBookSynchronouslyIfPermissionGranted];
        XCTAssertNotNil(contacts);
        XCTAssertGreaterThan([contacts count], 0);
        // Check for the first person in the default simulator address book, sorted
        // by first name which is how we sort the address book.
        // If this fails, probably need to reset all simulator data which will
        // reset to the default address book
        MAVEABPerson *person1 = [contacts objectAtIndex:0];
        XCTAssertEqualObjects(person1.firstName, @"Anna");
        XCTAssertEqualObjects(person1.lastName, @"Haro");
    } else {
        MAVEInfoLog(@"Addres book permission not granted, skipping test testLoadAddressBookSynchronouslyIfPermissionGranted");
    }
}

@end
