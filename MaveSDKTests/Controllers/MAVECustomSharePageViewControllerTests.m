//
//  MAVECustomSharePageViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVEShareToken.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEClientPropertyUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVECustomSharePageViewControllerTests : XCTestCase

@property (nonatomic, strong) MAVECustomSharePageViewController *viewController;
@property (nonatomic, strong) id viewControllerMock;
@property (nonatomic, strong) id sharerMock;
@property (nonatomic, strong) MAVERemoteConfiguration *remoteConfig;
@property (nonatomic, copy) NSString *applicationID;
@property (nonatomic, copy) NSString *shareToken;

@end

@implementation MAVECustomSharePageViewControllerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    self.applicationID = @"foo123";
    [MaveSDK setupSharedInstanceWithApplicationID:self.applicationID];
    self.viewController = nil;
    self.viewControllerMock = nil;
    self.sharerMock = nil;
    self.remoteConfig = nil;
    self.shareToken = nil;
}

- (void)tearDown {
    if (self.viewControllerMock) {
        [self.viewControllerMock stopMocking];
    }
    [super tearDown];
}

- (void)testViewDidLoadLogsInvitePageView {
    MAVECustomSharePageViewController *vc =
        [[MAVECustomSharePageViewController alloc] init];

    id apiMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiMock trackInvitePageOpenForPageType:MAVEInvitePageTypeCustomShare]);

    [vc viewDidLoad];

    OCMVerifyAll(apiMock);
}

@end