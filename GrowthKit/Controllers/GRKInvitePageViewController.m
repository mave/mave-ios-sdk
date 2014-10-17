//
//  InvitePageViewController.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowthKit.h"
#import "GRKInvitePageViewController.h"
#import "GRKABTableViewController.h"
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
    self.view = [self createContainerAndChildViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setContainerAndChildFramesWithKeyboardSize:kbSize];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize zeroSize = CGSizeMake(kbSize.width, 0);
    [self setContainerAndChildFramesWithKeyboardSize:zeroSize];
}


- (void)deviceWillRotate:(NSNotification *)notification {
    [self setContainerAndChildFramesWithKeyboardSize:CGSizeMake(0, 0)];
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
    CGSize appFrameSize = [[UIScreen mainScreen] applicationFrame].size;

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

- (UIView *)createContainerAndChildViews {
    CGRect cvf, tvf, imvf;
    [[self class]computeChildFramesWithKeyboardSize:CGSizeMake(0, 0)
                               createContainerFrame:&cvf
                                     tableViewFrame:&tvf
                             inviteMessageViewFrame:&imvf];
    UIView *containerView = [[UIView alloc] initWithFrame:cvf];

    self.ABTableViewController = [[GRKABTableViewController alloc] initAndCreateTableViewWithFrame:tvf];
    self.inviteMessageViewController = [[GRKInviteMessageViewController alloc] initAndCreateViewWithFrame:imvf];
    
    [self.inviteMessageViewController.messageView.sendButton addTarget:self
                                                           action:@selector(sendInvites)
                                                 forControlEvents:UIControlEventTouchUpInside];
     
    [containerView addSubview:self.ABTableViewController.tableView];
    [containerView addSubview:self.inviteMessageViewController.view];
    
    return containerView;
}

- (void)setContainerAndChildFramesWithKeyboardSize:(CGSize)kbSize {
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
