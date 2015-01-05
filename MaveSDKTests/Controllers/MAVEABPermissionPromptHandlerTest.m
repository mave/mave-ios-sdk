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
#import "MAVEABPermissionPromptHandler.h"


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
    OCMExpect([mock initializeObjectWithTimeout:2.0 completionBlock:
               [OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(id) = obj;
        completionBlock(remoteConfig);
        return YES;
    }]]);
    
    // Mock expected behavior
    id permissionPrompterMock = OCMPartialMock(permissionPrompter);
    

    // Run the method under test
    [permissionPrompter promptForContactsWithCompletionBlock:nil];

    OCMVerify([permissionPrompterMock
               showPrePromptAlertWithTitle:remoteConfig.contactsPrePromptTemplate.title
                                   message:remoteConfig.contactsPrePromptTemplate.message
                          cancelButtonCopy:remoteConfig.contactsPrePromptTemplate.cancelButtonCopy
                          acceptbuttonCopy:remoteConfig.contactsPrePromptTemplate.acceptButtonCopy]);
}

@end
