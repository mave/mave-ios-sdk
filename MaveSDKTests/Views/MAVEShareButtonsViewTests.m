//
//  MAVEShareIconsViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEShareButtonsView.h"
#import "MaveSDK.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVECustomSharePageView.h"
#import "MAVECustomSharePageViewController.h"

@interface MAVEShareButtonsViewTests : XCTestCase

@end

@implementation MAVEShareButtonsViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullInitMethod {
    MAVECustomSharePageViewController *delegate = [[MAVECustomSharePageViewController alloc] init];
    UIColor *iconColor = [UIColor redColor];
    UIColor *backgroundColor = [UIColor blackColor];
    UIFont *iconFont = [UIFont systemFontOfSize:11.35];


    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] initWithDelegate:delegate iconColor:iconColor iconFont:iconFont backgroundColor:backgroundColor useSmallIcons:YES];

    XCTAssertEqualObjects(view.delegate, delegate);
    XCTAssertNil(view.shareButtons);
    XCTAssertEqualObjects(view.iconColor, iconColor);
    XCTAssertEqualObjects(view.iconTextColor, iconColor);
    XCTAssertEqualObjects(view.iconFont, iconFont);
    XCTAssertEqualObjects(view.backgroundColor, backgroundColor);
    XCTAssertTrue(view.useSmallIcons);
    XCTAssertTrue(view.allowSMSShare);
}

- (void)testGenericButtonStyles {
    UIColor *iconColor = [UIColor redColor];
    UIColor *backgroundColor = [UIColor blackColor];
    UIFont *iconFont = [UIFont systemFontOfSize:11.25];

    id uiUtilsMock = OCMClassMock([MAVEBuiltinUIElementUtils class]);
    OCMExpect([uiUtilsMock tintWhitesInImage:[OCMArg any] withColor:iconColor]);

    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] initWithDelegate:nil iconColor:iconColor iconFont:iconFont backgroundColor:backgroundColor useSmallIcons:NO];
    UIButton *button = [view genericShareButtonWithIconNamed:@"MAVEShareIconSMS.png" andLabelText:@"FooBar"];

    OCMVerifyAll(uiUtilsMock);
    XCTAssertFalse(view.useSmallIcons);
    XCTAssertEqualObjects(button.currentTitle, @"FooBar");
    XCTAssertEqualObjects(button.currentTitleColor, iconColor);
    XCTAssertEqualObjects(button.titleLabel.font,
                          iconFont);
    XCTAssertEqualObjects(view.backgroundColor, backgroundColor);
}

@end
