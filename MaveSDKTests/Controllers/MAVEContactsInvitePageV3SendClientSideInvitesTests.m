//
//  MAVEContactsInvitePageV3SendClientSideInvitesTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 7/21/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "MAVEContactsInvitePageV3ViewController.h"
#import "MAVESharer.h"

@interface MAVEContactsInvitePageV3SendClientSideInvitesTests : XCTestCase

@end

@interface MAVEContactsInvitePageV3ViewController(Testing)
- (void)_syncSendClientSideGroupInvitesToSelected;
@end

@implementation MAVEContactsInvitePageV3SendClientSideInvitesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSendClientSideInvitesSMSAndEmail {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p0.emailObjects = @[email00, email01];
    p0.selected = YES; email00.selected = YES; email01.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p0];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    p1.selected = YES; phone1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];

    // Mock sharer to test that we launched sms and email share pages
    id sharerMock = OCMClassMock([MAVESharer class]);
    NSArray *invitePhones = @[phone1.value];
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:invitePhones completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMessageComposeViewController *, MessageComposeResult) = obj;
        completionBlock(nil, MessageComposeResultSent);
        return YES;
    }]]);
    NSArray *inviteEmails = @[email00.value];
    OCMExpect([sharerMock composeClientEmailInviteToRecipientEmails:inviteEmails withCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMailComposeViewController *, MFMailComposeResult) = obj;
        completionBlock(nil, MFMailComposeResultSent);
        return YES;
    }]]);

    [controller _syncSendClientSideGroupInvitesToSelected];

    OCMVerifyAll(sharerMock);
    // after sending, people should no longer be selected

    // Wait for them to become unselected on main run loop.
    // (can't just wait here using GCD b/c test is running on main loop so if we
    // block then any dispatches to main queue in the code won't ever run)
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
        if (!p0.selected && !p1.selected) {
            break;
        }
    }
    XCTAssertFalse(p0.selected);
    XCTAssertFalse(p1.selected);
}

- (void)testSendClientSideInvitesSMSAndEmailWhenSMSNotSent {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p0.emailObjects = @[email00, email01];
    p0.selected = YES; email00.selected = YES; email01.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p0];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    p1.selected = YES; phone1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];

    // Mock sharer to test that we launched sms and email share pages
    id sharerMock = OCMClassMock([MAVESharer class]);
    NSArray *invitePhones = @[phone1.value];
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:invitePhones completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMessageComposeViewController *, MessageComposeResult) = obj;
        completionBlock(nil, MessageComposeResultCancelled);
        return YES;
    }]]);
    NSArray *inviteEmails = @[email00.value];
    OCMExpect([sharerMock composeClientEmailInviteToRecipientEmails:inviteEmails withCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMailComposeViewController *, MFMailComposeResult) = obj;
        completionBlock(nil, MFMailComposeResultSent);
        return YES;
    }]]);

    [controller _syncSendClientSideGroupInvitesToSelected];

    OCMVerifyAll(sharerMock);
    // after sending, person with email should still be selected but person with
    // phone should not

    // Wait for them to become unselected on main run loop.
    // (can't just wait here using GCD b/c test is running on main loop so if we
    // block then any dispatches to main queue in the code won't ever run)
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
        if (!p0.selected) {
            break;
        }
    }
    XCTAssertFalse(p0.selected);
    XCTAssertTrue(p1.selected);
}

- (void)testSendClientSideInvitesSMSAndEmailWhenEmailNotSent {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p0.emailObjects = @[email00, email01];
    p0.selected = YES; email00.selected = YES; email01.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p0];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    p1.selected = YES; phone1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];

    // Mock sharer to test that we launched sms and email share pages
    id sharerMock = OCMClassMock([MAVESharer class]);
    NSArray *invitePhones = @[phone1.value];
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:invitePhones completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMessageComposeViewController *, MessageComposeResult) = obj;
        completionBlock(nil, MessageComposeResultSent);
        return YES;
    }]]);
    NSArray *inviteEmails = @[email00.value];
    OCMExpect([sharerMock composeClientEmailInviteToRecipientEmails:inviteEmails withCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMailComposeViewController *, MFMailComposeResult) = obj;
        completionBlock(nil, MFMailComposeResultSaved);
        return YES;
    }]]);

    [controller _syncSendClientSideGroupInvitesToSelected];

    OCMVerifyAll(sharerMock);
    // after sending, person with email should still be selected but person with
    // phone should not

    // Wait for them to become unselected on main run loop.
    // (can't just wait here using GCD b/c test is running on main loop so if we
    // block then any dispatches to main queue in the code won't ever run)
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
        if (!p1.selected) {
            break;
        }
    }
    XCTAssertTrue(p0.selected);
    XCTAssertFalse(p1.selected);
}

- (void)testSendClientSideInvitesSMSOnly {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    p1.selected = YES; phone1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];

    // Mock sharer to test that we launched sms and email share pages
    id sharerMock = OCMClassMock([MAVESharer class]);
    NSArray *invitePhones = @[phone1.value];
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:invitePhones completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMessageComposeViewController *, MessageComposeResult) = obj;
        completionBlock(nil, MessageComposeResultSent);
        return YES;
    }]]);
    [[sharerMock reject] composeClientEmailInviteToRecipientEmails:[OCMArg any] withCompletionBlock:[OCMArg any]];

    [controller _syncSendClientSideGroupInvitesToSelected];

    OCMVerifyAll(sharerMock);
    // after sending, people should no longer be selected

    // Wait for them to become unselected on main run loop.
    // (can't just wait here using GCD b/c test is running on main loop so if we
    // block then any dispatches to main queue in the code won't ever run)
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
        if (!p1.selected) {
            break;
        }
    }
    XCTAssertFalse(p1.selected);
}

- (void)testSendClientSideInvitesEmailOnly {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p0.emailObjects = @[email00, email01];
    p0.selected = YES; email00.selected = YES; email01.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p0];

    // Mock sharer to test that we launched sms and email share pages
    id sharerMock = OCMClassMock([MAVESharer class]);
    [[sharerMock reject] composeClientSMSInviteToRecipientPhones:[OCMArg any] completionBlock:[OCMArg any]];

    NSArray *inviteEmails = @[email00.value];
    OCMExpect([sharerMock composeClientEmailInviteToRecipientEmails:inviteEmails withCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(MFMailComposeViewController *, MFMailComposeResult) = obj;
        completionBlock(nil, MFMailComposeResultSent);
        return YES;
    }]]);

    [controller _syncSendClientSideGroupInvitesToSelected];

    OCMVerifyAll(sharerMock);
    // after sending, people should no longer be selected

    // Wait for them to become unselected on main run loop.
    // (can't just wait here using GCD b/c test is running on main loop so if we
    // block then any dispatches to main queue in the code won't ever run)
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
        if (!p0.selected) {
            break;
        }
    }
    XCTAssertFalse(p0.selected);
}


@end
