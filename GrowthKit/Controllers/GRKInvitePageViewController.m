//
//  InvitePageViewController.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "GrowthKit.h"
#import "GRKInvitePageViewController.h"
#import "GRKABTableViewController.h"
#import "GRKABCollection.h"
#import "GRKInviteMessageViewController.h"

@interface GRKInvitePageViewController ()

@end

@implementation GRKInvitePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Invite Page viewDidLoad");
    // Do any additional setup after loading the view.

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(keyboardWillShow:)
                          name:UIKeyboardWillShowNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(keyboardWillHide:)
                          name:UIKeyboardWillHideNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(deviceWillRotate:)
                          name:UIDeviceOrientationDidChangeNotification
                        object:nil];

    // Register the viewed invite page event with our API
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk.HTTPManager sendInvitePageOpen:gk.currentUserId];
}

- (void)loadView {
    [super loadView];
    NSLog(@"Invite Page loadView!");
    [self setupNavgationBar];
    [self determineAndSetViewBasedOnABPermissions];
}

- (void)determineAndSetViewBasedOnABPermissions {
    // If address book permission already granted, load contacts view right now
    ABAuthorizationStatus addrBookStatus = ABAddressBookGetAuthorizationStatus();
    if (addrBookStatus == kABAuthorizationStatusAuthorized) {
        self.view = [self createAddressBookInviteViewWithData:nil];
        [GRKABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ABTableViewController updateTableData:indexedData];
            });
         }];

    // If status not determined, prompt for permission then load data
    // If permission not granted, leave blank for now
    } else if (addrBookStatus == kABAuthorizationStatusNotDetermined) {
        self.view = [self createEmptyFallbackView];
        [GRKABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
            if ([indexedData count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     self.view = [self createAddressBookInviteViewWithData:indexedData];
                });
            }
         }];

    // If status already denied, leave blank page for now
    } else if (addrBookStatus == kABAuthorizationStatusDenied ||
               addrBookStatus == kABAuthorizationStatusRestricted) {
        self.view = [self createEmptyFallbackView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setOwnAndSubviewFramesWithKeyboardSize:kbSize];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self setOwnAndSubviewFramesWithKeyboardSize:CGSizeMake(0, 0)];
}


- (void)deviceWillRotate:(NSNotification *)notification {
    [self setOwnAndSubviewFramesWithKeyboardSize:CGSizeMake(0, 0)];
}


- (void)cleanupForDismiss {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillShowNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillHideNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:UIDeviceOrientationDidChangeNotification
                           object:nil];
}

+ (void)computeChildFramesWithKeyboardSize:(CGSize)kbSize
                      createContainerFrame:(CGRect *)containerFrame
                            tableViewFrame:(CGRect *)tableViewFrame
                    inviteMessageViewFrame:(CGRect *)inviteMessageViewFrame {
    *containerFrame = [self fullAppFrame];
    CGSize appFrameSize = containerFrame->size;

    float extraVerticalPadding = 0;
    if (![UIApplication sharedApplication].statusBarHidden) {
        // 20 is to account for the top menu bar which always overlays your app in ios7+
        extraVerticalPadding = 20;
    }

    float inviteViewHeight = 70;
    float tableViewHeight = appFrameSize.height - inviteViewHeight - kbSize.height + extraVerticalPadding;

    // Set pointers to return multi
    *containerFrame = CGRectMake(0, 0, appFrameSize.width, appFrameSize.height);
    *tableViewFrame = CGRectMake(0, 0, appFrameSize.width, tableViewHeight);
    *inviteMessageViewFrame = CGRectMake(0, tableViewHeight, appFrameSize.width, inviteViewHeight);
}

+ (CGRect)fullAppFrame {
    CGSize appFrameSize = [[UIScreen mainScreen] applicationFrame].size;
    return CGRectMake(0, 0, appFrameSize.width, appFrameSize.height);
}

- (UIView *)createEmptyFallbackView {
    UIView *view = [[UIView alloc] initWithFrame:[[self class] fullAppFrame]];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}

- (UIView *)createAddressBookInviteViewWithData:(NSDictionary *)indexedAddressBook {
    CGRect cvf, tvf, imvf;
    [[self class]computeChildFramesWithKeyboardSize:CGSizeMake(0, 0)
                               createContainerFrame:&cvf
                                     tableViewFrame:&tvf
                             inviteMessageViewFrame:&imvf];
    UIView *containerView = [[UIView alloc] initWithFrame:cvf];

    self.ABTableViewController = [[GRKABTableViewController alloc] initWithFrame:tvf andData:indexedAddressBook];
    self.inviteMessageViewController = [[GRKInviteMessageViewController alloc] initAndCreateViewWithFrame:imvf];

    [self.inviteMessageViewController.messageView.sendButton addTarget:self
                                                           action:@selector(sendInvites)
                                                 forControlEvents:UIControlEventTouchUpInside];

    [containerView addSubview:self.ABTableViewController.tableView];
    [containerView addSubview:self.inviteMessageViewController.view];
    
    return containerView;
}

- (void)setOwnAndSubviewFramesWithKeyboardSize:(CGSize)kbSize {
    CGRect cvf, tvf, imvf;
    [[self class]computeChildFramesWithKeyboardSize:kbSize
                               createContainerFrame:&cvf
                                     tableViewFrame:&tvf
                             inviteMessageViewFrame:&imvf];
    [self.view setFrame:cvf];
    [self.ABTableViewController.tableView setFrame:tvf];
    [self.inviteMessageViewController.view setFrame:imvf];
}

- (void)setupNavgationBar {
    self.navigationItem.title = @"Invite Friends";
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(dismissAfterCancel:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)dismissAfterCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self cleanupForDismiss];
}

- (void)sendInvites {
    NSLog(@"Sending invites");
    NSArray *phones = [self.ABTableViewController.selectedPhoneNumbers allObjects];
    NSString *message = self.inviteMessageViewController.messageView.textField.text;
    if ([phones count] == 0) {
        NSLog(@"Pressed Send but no recipients selected");
        return;
    }
    
    GRKHTTPManager *httpManager = [GrowthKit sharedInstance].HTTPManager;
    [httpManager sendInvitesWithPersons:phones message:message completionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error != nil) {
            NSLog(@"Invites failed to send, error: %@, response: %@", error, responseData);
        } else {
            NSLog(@"Invites sent! response: %@", responseData);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inviteMessageViewController.sendingInProgressView completeSendingProgress];
        });
    }];
    [self.inviteMessageViewController switchToSendingInProgressView:self.view];
}

@end
