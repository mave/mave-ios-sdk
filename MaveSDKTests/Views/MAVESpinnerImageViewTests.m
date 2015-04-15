//
//  MAVESpinnerImageViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/13/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVESpinnerImageView.h"

@interface MAVESpinnerImageViewTests : XCTestCase

@end

@implementation MAVESpinnerImageViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetupSpinner {
    MAVESpinnerImageView *spinnerView = [[MAVESpinnerImageView alloc] init];
    XCTAssertNotNil(spinnerView);
    XCTAssertEqual([spinnerView.animationImages count], 12);
    XCTAssertEqual(spinnerView.animationDuration, 0.7f);
    XCTAssertEqual(spinnerView.animationRepeatCount, 0);
}


@end
