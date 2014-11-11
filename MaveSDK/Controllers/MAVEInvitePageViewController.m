//
//  InvitePageViewController.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "MaveSDK.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEABTableViewController.h"
#import "MAVEABCollection.h"
#import "MAVEInviteMessageViewController.h"
#import "MAVENoAddressBookPermissionView.h"

@interface MAVEInvitePageViewController ()

@end

@implementation MAVEInvitePageViewController

- (void)loadView {
    [super loadView];
    // On load keyboard is hidden
    self.isKeyboardVisible = NO;
    self.keyboardFrame = [self keyboardFrameWhenHidden];

    [self setupNavigationBar];
    [self determineAndSetViewBasedOnABPermissions];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Subscribe to events that change frame size
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(keyboardWillChangeFrame:)
                          name:UIKeyboardWillChangeFrameNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(deviceDidRotate:)
                          name:UIDeviceOrientationDidChangeNotification
                        object:nil];

    // Register the viewed invite page event with our API
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk.HTTPManager trackInvitePageOpenRequest:gk.userData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Cleanup to dismiss, then call the block method, passing back the
// number of invites sent to the containing app
- (void)dismissSelf:(unsigned int)numberOfInvitesSent {
    // Cleanup for dismiss
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillChangeFrameNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:UIDeviceOrientationDidChangeNotification
                           object:nil];
    // Call dismissal block
    InvitePageDismissalBlock dismissalBlock = [MaveSDK sharedInstance].invitePageDismissalBlock;
    dismissalBlock(self, numberOfInvitesSent);
}

- (void)dismissAfterCancel {
    [self dismissSelf:0];
}

//
// Handle frame changing events
//

// returns what the frame would be for a hidden keyboard (origin below app frame)
// based on  current application frame
- (CGRect)keyboardFrameWhenHidden {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    return CGRectMake(0, appFrame.origin.y + appFrame.size.height, 0, 0);
}

- (void)deviceDidRotate:(NSNotification *)notification {
    // If keyboard is visible during rotate, the keyboard frame change event will
    // resize our view correctly so no need to do anything here
    if (!self.isKeyboardVisible) {
        self.keyboardFrame = [self keyboardFrameWhenHidden];
        [self setOwnAndSubviewFrames];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    self.keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.keyboardFrame.origin.y == [self keyboardFrameWhenHidden].origin.y) {
        self.isKeyboardVisible = NO;
    } else {
        self.isKeyboardVisible = YES;
    }
    [self setOwnAndSubviewFrames];
}

//
// Load the correct view(s) with data
//
- (void)setupNavigationBar {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    
    self.navigationItem.title = @"Invite Friends";
    self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName: displayOptions.navigationBarTitleColor,
            NSFontAttributeName: displayOptions.navigationBarTitleFont,
    };
    self.navigationController.navigationBar.barTintColor = displayOptions.navigationBarBackgroundColor;
    
    UIBarButtonItem *cancelBarButtonItem = displayOptions.navigationBarCancelButton;
    cancelBarButtonItem.target = self;
    cancelBarButtonItem.action = @selector(dismissAfterCancel);
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
}

- (void)determineAndSetViewBasedOnABPermissions {
    // If address book permission already granted, load contacts view right now
    ABAuthorizationStatus addrBookStatus = ABAddressBookGetAuthorizationStatus();
    if (addrBookStatus == kABAuthorizationStatusAuthorized) {
        self.view = [self createAddressBookInviteView];
        [MAVEABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ABTableViewController updateTableData:indexedData];
            });
         }];

    // If status not determined, prompt for permission then load data
    // If permission not granted, swap empty for for permission denied view
    } else if (addrBookStatus == kABAuthorizationStatusNotDetermined) {
        self.view = [self createEmptyFallbackView];
        [MAVEABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
            if ([indexedData count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.view = [self createAddressBookInviteView];
                    [self.ABTableViewController updateTableData:indexedData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.view = [[MAVENoAddressBookPermissionView alloc] init];
                });
            }
         }];

    // If status already denied, leave blank page for now
    } else if (addrBookStatus == kABAuthorizationStatusDenied ||
               addrBookStatus == kABAuthorizationStatusRestricted) {
        self.view = [self createEmptyFallbackView];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view = [[MAVENoAddressBookPermissionView alloc] init];
        });
    }
}

+ (void)computeChildFramesWithKeyboardFrame:(CGRect)kbFrame
                       createContainerFrame:(CGRect *)containerFrame
                             tableViewFrame:(CGRect *)tableViewFrame
                     inviteMessageViewFrame:(CGRect *)inviteMessageViewFrame {
    // Our container frame should go from top of screen (will be overlapped by status bar if it's visible)
    // to the top of the keyboard, and full width of application frame
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    *containerFrame = CGRectMake(0,
                                 0,
                                 appFrame.origin.x + appFrame.size.width,
                                 kbFrame.origin.y);

    // Invite and table view fill the container frame vertically
    float inviteViewHeight = 70; // Temporarily hard-coded
    *tableViewFrame = CGRectMake(containerFrame->origin.x,
                                 containerFrame->origin.y,
                                 containerFrame->size.width,
                                 containerFrame->size.height - inviteViewHeight);
    *inviteMessageViewFrame = CGRectMake(containerFrame->origin.x,
                                         tableViewFrame->origin.y + tableViewFrame->size.height,
                                         containerFrame->size.width,
                                         inviteViewHeight);
}

- (UIView *)createEmptyFallbackView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}

- (UIView *)createAddressBookInviteView {
    CGRect cvf, tvf, imvf;
    [[self class]computeChildFramesWithKeyboardFrame:self.keyboardFrame
                               createContainerFrame:&cvf
                                     tableViewFrame:&tvf
                             inviteMessageViewFrame:&imvf];
    UIView *containerView = [[UIView alloc] initWithFrame:cvf];

    self.ABTableViewController = [[MAVEABTableViewController alloc] initTableViewWithFrame:tvf
                                                                                   parent:self];
    self.inviteMessageViewController = [[MAVEInviteMessageViewController alloc] initAndCreateViewWithFrame:imvf];

    [self.inviteMessageViewController.messageView.sendButton addTarget:self
                                                           action:@selector(sendInvites)
                                                 forControlEvents:UIControlEventTouchUpInside];

    [containerView addSubview:self.ABTableViewController.tableView];
    [containerView addSubview:self.inviteMessageViewController.view];
    
    return containerView;
}

- (void)setOwnAndSubviewFrames {
    CGRect cvf, tvf, imvf;
    [[self class]computeChildFramesWithKeyboardFrame:self.keyboardFrame
                                createContainerFrame:&cvf
                                      tableViewFrame:&tvf
                              inviteMessageViewFrame:&imvf];
    [self.view setFrame:cvf];
    [self.ABTableViewController.tableView setFrame:tvf];
    [self.inviteMessageViewController.view setFrame:imvf];
}
//
// Respond to children's Events
//

- (void)ABTableViewControllerNumberSelectedChanged:(unsigned long)num {
    // If called from the table view's "did select row at index path" method we'll already be
    // in the main thread anyway, but dispatch it asynchronously just in case we ever call
    // from somewhere else.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.inviteMessageViewController.messageView updateNumberPeopleSelected:num];
    });
}


//
// Send invites and update UI when done
//
- (void)sendInvites {
    NSLog(@"Sending invites");
    NSArray *phones = [self.ABTableViewController.selectedPhoneNumbers allObjects];
    NSString *message = self.inviteMessageViewController.messageView.textField.text;
    if ([phones count] == 0) {
        NSLog(@"Pressed Send but no recipients selected");
        return;
    }
    
    MaveSDK *gk = [MaveSDK sharedInstance];
    MAVEHTTPManager *httpManager = gk.HTTPManager;
    [httpManager sendInvitesWithPersons:phones message:message userId:gk.userData.userID completionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error != nil) {
            NSLog(@"Invites failed to send, error: %@, response: %@",
                  error, responseData);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.inviteMessageViewController switchToInviteMessageView:self.view];
                [self showErrorAndResetAfterSendInvitesFailure:error];
            });
        } else {
            NSLog(@"Invites sent! response: %@", responseData);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.inviteMessageViewController.sendingInProgressView completeSendingProgress];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissSelf:(unsigned int)[phones count]];
            });
        }
    }];
    [self.inviteMessageViewController switchToSendingInProgressView:self.view];
}

- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invites not sent"
                                                    message:@"Server was unavailable or internet connection failed"
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [self performSelector:@selector(dismissSendInvitesFailedAlertView:)
               withObject:alert
               afterDelay:3.0];
}

- (void)dismissSendInvitesFailedAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
