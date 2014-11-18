//
//  MAVEInviteCopyViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/18/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEInviteCopyView.h"

@interface MAVEInviteCopyViewTests : XCTestCase

@end

@implementation MAVEInviteCopyViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEInviteCopyView *copyView = [[MAVEInviteCopyView alloc] init];
    XCTAssertNotNil(copyView);
    XCTAssertNotNil(copyView.messageCopy);
    XCTAssertEqualObjects(copyView.backgroundColor, [UIColor whiteColor]);
    //XCTAssertEqualObjects(copyView.messageCopy.font, <#expression2, ...#>)
    //XCTAssertEqualObjects(copyView.messageCopy.textColor, <#expression2, ...#>)
    //XCTAssertEqualObjects(copyView.messageCopy.text, <#expression2, ...#>)
    XCTAssertEqual(copyView.messageCopy.textAlignment, NSTextAlignmentCenter);
    XCTAssertEqual(copyView.messageCopy.lineBreakMode, NSLineBreakByWordWrapping);
    XCTAssertEqual([copyView.subviews count], 1);
}

- (void)testLayoutComputeHeight {
    // Set some default values
    CGFloat viewWidth = 200;
    // Expected taken by running once with our default values
    CGFloat expectedViewHeight = 74.5;
    MAVEInviteCopyView *copyView = [[MAVEInviteCopyView alloc] init];
    CGSize labelSize = [copyView messageCopyLabelSizeWithWidth:viewWidth];
    XCTAssertEqual(labelSize.width, viewWidth - 2*15);
    XCTAssertEqual(labelSize.height, expectedViewHeight - 2*12);
    
    XCTAssertEqual([copyView computeHeightWithWidth:viewWidth], expectedViewHeight);
}

@end
