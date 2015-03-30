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

@end
