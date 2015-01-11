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

- (void)testInitStyles {
    MAVECustomSharePageView *view = [[MAVECustomSharePageView alloc] init];
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    XCTAssertEqualObjects(view.backgroundColor,
                          opts.sharePageBackgroundColor);
    XCTAssertEqualObjects(view.shareExplanationLabel.font,
                          opts.sharePageExplanationFont);
    XCTAssertEqualObjects(view.shareExplanationLabel.textColor,
                          opts.sharePageExplanationTextColor);
}

- (void)testGenericButtonStyles {
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    id uiUtilsMock = OCMClassMock([MAVEBuiltinUIElementUtils class]);
    OCMExpect([uiUtilsMock tintWhitesInImage:[OCMArg any] withColor:opts.sharePageIconColor]);

    MAVECustomSharePageView *view = [[MAVECustomSharePageView alloc] init];
    UIButton *button = [view genericShareButtonWithIconNamed:@"MAVEShareIconSMS.png" andLabelText:@"FooBar"];

    OCMVerifyAll(uiUtilsMock);
    XCTAssertEqualObjects(button.currentTitle, @"FooBar");
    XCTAssertEqualObjects(button.currentTitleColor,
                          opts.sharePageIconTextColor);
    XCTAssertEqualObjects(button.titleLabel.font,
                          opts.sharePageIconFont);
}

@end
