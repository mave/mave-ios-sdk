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

- (instancetype)initWithDelegate:(id <GRKInvitePageDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

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
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk.HTTPManager sendInvitePageOpen:gk.currentUserId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Wrap the delegate cancel & success to make sure we cleanup first
- (void)dismissAfterSuccess {
    [self.delegate userDidSendInvites];
}

- (void)dismissAfterCancel {
    [self cleanupForDismiss];
    [self.delegate userDidCancel];
}

- (void)cleanupForDismiss {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillChangeFrameNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:UIDeviceOrientationDidChangeNotification
                           object:nil];
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
    self.navigationItem.title = @"Invite Friends";
    self.navigationController.navigationBar.barTintColor = [GrowthKit sharedInstance].displayOptions.navigationBarBackgroundColor;
    
    UIBarButtonItem * cancelBarButtonItem;
    if ([self.delegate respondsToSelector:@selector(cancelBarButtonItem)]) {
        cancelBarButtonItem = [self.delegate cancelBarButtonItem];
    } else {
        cancelBarButtonItem = [[UIBarButtonItem alloc] init];
        cancelBarButtonItem.title = @"Cancel";
    }
    cancelBarButtonItem.target = self;
    cancelBarButtonItem.action = @selector(dismissAfterSuccess);
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
}

- (void)determineAndSetViewBasedOnABPermissions {
    // If address book permission already granted, load contacts view right now
    ABAuthorizationStatus addrBookStatus = ABAddressBookGetAuthorizationStatus();
    if (addrBookStatus == kABAuthorizationStatusAuthorized) {
        self.view = [self createAddressBookInviteView];
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
                    self.view = [self createAddressBookInviteView];
                    [self.ABTableViewController updateTableData:indexedData];
                });
            }
         }];

    // If status already denied, leave blank page for now
    } else if (addrBookStatus == kABAuthorizationStatusDenied ||
               addrBookStatus == kABAuthorizationStatusRestricted) {
        self.view = [self createEmptyFallbackView];
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

    self.ABTableViewController = [[GRKABTableViewController alloc] initTableViewWithFrame:tvf
                                                                                   parent:self];
    self.inviteMessageViewController = [[GRKInviteMessageViewController alloc] initAndCreateViewWithFrame:imvf];

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

- (void)ABTableViewControllerUpdatedNumberSelected:(unsigned long)num {
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
    
    GrowthKit *gk = [GrowthKit sharedInstance];
    GRKHTTPManager *httpManager = gk.HTTPManager;
    [httpManager sendInvitesWithPersons:phones message:message userId:gk.currentUserId completionBlock:^(NSError *error, NSDictionary *responseData) {
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
            dispatch_after(1.0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self cleanupForDismiss];
                [self.delegate userDidSendInvites];
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
