//
//  MAVECustomSharePageViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVECustomSharePageView.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEBuiltinUIElementUtils.h"

@interface MAVECustomSharePageViewTests : XCTestCase

@end

@implementation MAVECustomSharePageViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    [MaveSDK sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitConfigurationAndStyles {
    NSString *expectedLabelText = [MaveSDK sharedInstance].remoteConfiguration.customSharePage.explanationCopy;
    XCTAssertGreaterThan([expectedLabelText length], 0);

    MAVECustomSharePageView *view = [[MAVECustomSharePageView alloc] init];
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    XCTAssertEqualObjects(view.backgroundColor,
                          opts.sharePageBackgroundColor);
    XCTAssertEqualObjects(view.shareExplanationLabel.font,
                          opts.sharePageExplanationFont);
    XCTAssertEqualObjects(view.shareExplanationLabel.text,
                          expectedLabelText);
    XCTAssertEqualObjects(view.shareExplanationLabel.textColor,
                          opts.sharePageExplanationTextColor);

    // share icons view
    XCTAssertNotNil(view.shareIconsView);
    XCTAssertTrue([view.shareIconsView isDescendantOfView:view]);
}

- (void)testInitSetsAllowedSharesFromRemoteConfig {
    MAVERemoteConfiguration *overrideRemoteConfig = [[MAVERemoteConfiguration alloc] init];
    overrideRemoteConfig.customSharePage = [[MAVERemoteConfigurationCustomSharePage alloc] init];
    overrideRemoteConfig.customSharePage.includeClientSMS = NO;
    overrideRemoteConfig.customSharePage.includeClientEmail = YES;
    overrideRemoteConfig.customSharePage.includeNativeFacebook = NO;
    overrideRemoteConfig.customSharePage.includeNativeTwitter = YES;
    overrideRemoteConfig.customSharePage.includeClipboard = NO;

    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMStub([maveMock remoteConfiguration]).andReturn(overrideRemoteConfig);

    MAVECustomSharePageView *view = [[MAVECustomSharePageView alloc] init];
    XCTAssertFalse(view.shareIconsView.allowSMSShare);
    XCTAssertTrue(view.shareIconsView.allowEmailShare);
    XCTAssertFalse(view.shareIconsView.allowNativeFacebookShare);
    XCTAssertTrue(view.shareIconsView.allowNativeTwitterShare);
    XCTAssertFalse(view.shareIconsView.allowClipboardShare);
}

@end
