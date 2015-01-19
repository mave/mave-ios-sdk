//
//  MAVESearchBarTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/19/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVESearchBar.h"
#import "MaveSDK.h"
#import "MAVEDisplayOptionsFactory.h"

@interface MAVESearchBarTests : XCTestCase

@end

@implementation MAVESearchBarTests

- (void)setUp {
    [super setUp];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    [MaveSDK sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetupWithDisplayOptions {
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    MAVESearchBar *searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];
    XCTAssertEqualObjects(searchBar.backgroundColor, opts.searchBarBackgroundColor);

    NSAttributedString *expectedAttributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter name or phone number" attributes:@{NSForegroundColorAttributeName: opts.searchBarPlaceholderTextColor, NSFontAttributeName: opts.searchBarFont}];
    XCTAssertEqualObjects(searchBar.attributedPlaceholder, expectedAttributedPlaceholder);

    XCTAssertEqualObjects(searchBar.textColor, opts.searchBarSearchTextColor);
    XCTAssertEqualObjects(searchBar.text, @"");
    UILabel *toFieldLabel = [searchBar.leftView.subviews objectAtIndex:0];
    XCTAssertEqualObjects(toFieldLabel.text, @"To:");
    XCTAssertEqualObjects(toFieldLabel.textColor, opts.searchBarPlaceholderTextColor);
}

@end
