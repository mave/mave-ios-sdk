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
#import "MAVEShareIconsView.h"
#import "MaveSDK.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVECustomSharePageView.h"

@interface MAVEShareIconsViewTests : XCTestCase

@end

@implementation MAVEShareIconsViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenericButtonStyles {
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    id uiUtilsMock = OCMClassMock([MAVEBuiltinUIElementUtils class]);
    OCMExpect([uiUtilsMock tintWhitesInImage:[OCMArg any] withColor:opts.sharePageIconColor]);

    MAVEShareIconsView *view = [[MAVEShareIconsView alloc] initWithDelegate:nil];
    UIButton *button = [view genericShareButtonWithIconNamed:@"MAVEShareIconSMS.png" andLabelText:@"FooBar"];

    OCMVerifyAll(uiUtilsMock);
    XCTAssertEqualObjects(button.currentTitle, @"FooBar");
    XCTAssertEqualObjects(button.currentTitleColor,
                          opts.sharePageIconTextColor);
    XCTAssertEqualObjects(button.titleLabel.font,
                          opts.sharePageIconFont);
}

@end
