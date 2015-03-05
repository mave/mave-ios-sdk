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
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVECustomSharePageView.h"
#import "MAVENoAddressBookPermissionView.h"
#import "MAVEConstants.h"
#import "MAVESearchBar.h"

#import <Social/Social.h>


@interface MAVEInvitePageViewController ()

@end

@implementation MAVEInvitePageViewController

- (void)loadView {
    [super loadView];
    // On load keyboard is hidden
    self.isKeyboardVisible = NO;
    self.keyboardFrame = [self keyboardFrameWhenHidden];

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
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.view endEditing:YES];
}

- (void)dealloc {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillChangeFrameNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:UIDeviceOrientationDidChangeNotification
                           object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Cleanup to dismiss, then call the block method, passing back the
// number of invites sent to the containing app
- (void)dismissSelf:(NSUInteger)numberOfInvitesSent {
    [[MaveSDK sharedInstance].invitePageChooser dismissOnSuccess:numberOfInvitesSent];
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
        [self layoutInvitePageViewAndSubviews];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    self.keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.keyboardFrame.origin.y == [self keyboardFrameWhenHidden].origin.y) {
        self.isKeyboardVisible = NO;
    } else {
        self.isKeyboardVisible = YES;
    }
    [self layoutInvitePageViewAndSubviews];
}

- (BOOL)shouldDisplayInviteMessageView {
    if ([self.ABTableViewController.selectedPhoneNumbers count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

//
// Load the correct view(s) with data
//


- (void)buildContactsToUseAtPageRender:(NSDictionary **)suggestedContactsReturnVal
            addSuggestedLaterWhenReady:(BOOL *)addSuggestedLaterReturnVal
                      fromContactsList:(NSArray *)contacts {
    BOOL suggestionsEnabled = [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.suggestedInvitesEnabled;
    if (!suggestionsEnabled) {
        *suggestedContactsReturnVal = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
        *addSuggestedLaterReturnVal = NO;
        return;
    }
    BOOL suggestionsReady = [MaveSDK sharedInstance].suggestedInvitesBuilder.promise.status != MAVEPromiseStatusUnfulfilled;
    if (!suggestionsReady) {
        NSDictionary *indexedContacts = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
        *suggestedContactsReturnVal = [MAVEABUtils combineSuggested:@[] intoABIndexedForTableSections:indexedContacts];
        *addSuggestedLaterReturnVal = YES;
        return;
    }

    NSArray *suggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:0];
    NSDictionary *indexedContacts = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
    if ([suggestions count] > 0) {
        *suggestedContactsReturnVal = [MAVEABUtils combineSuggested:suggestions intoABIndexedForTableSections:indexedContacts];
    } else {
        *suggestedContactsReturnVal = indexedContacts;
    }
    *addSuggestedLaterReturnVal = NO;
}


// TODO: unit test this method
- (void)determineAndSetViewBasedOnABPermissions {
    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock: ^(NSArray *contacts) {
        // Permission denied
        if ([contacts count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MaveSDK sharedInstance].invitePageChooser replaceActiveViewControllerWithSharePage];
            });
        // Permission granted
        } else {
            NSDictionary *indexedContactsToRenderNow;
            BOOL updateSuggestionsWhenReady = NO;
            [self buildContactsToUseAtPageRender:&indexedContactsToRenderNow
                      addSuggestedLaterWhenReady:&updateSuggestionsWhenReady
                                fromContactsList:contacts];
            if (updateSuggestionsWhenReady) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSArray *suggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:10];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.ABTableViewController updateTableDataAnimatedWithSuggestedInvites:suggestions];

                    });
                });
            }

            // Render the contacts we have now regardless
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ABTableViewController updateTableData:indexedContactsToRenderNow];
                [self layoutInvitePageViewAndSubviews];

                // Only if permission was granted should we log that we displayed
                // the invite page with an address book list
                [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeContactList];
            });
        }
    }];

    // Use address book invite as background while prompting for permission)
    self.view = [self createAddressBookInviteView];
    [self layoutInvitePageViewAndSubviews];
}

- (UIView *)createAddressBookInviteView {
    // Instantiate the view controllers for child views
    self.abTableFixedSearchbar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];
    self.ABTableViewController = [[MAVEABTableViewController alloc] initTableViewWithParent:self];
    self.bottomActionContainerView = [[MAVEInvitePageBottomActionContainerView alloc] init];
    [self.bottomActionContainerView.inviteMessageView.sendButton
        addTarget:self action:@selector(sendInvites) forControlEvents: UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    self.bottomActionContainerView.inviteMessageView.textViewContentChangingBlock = ^void() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf layoutInvitePageViewAndSubviews];
        });
    };
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:self.abTableFixedSearchbar];
    [containerView addSubview:self.ABTableViewController.tableView];
    [containerView addSubview:self.bottomActionContainerView];
    return containerView;
}

- (void)layoutInvitePageViewAndSubviews {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

    CGRect containerFrame = CGRectMake(0,
                                       0,
                                       appFrame.origin.x + appFrame.size.width,
                                       self.keyboardFrame.origin.y);

    CGFloat yOffsetForContent = appFrame.origin.y + self.navigationController.navigationBar.frame.size.height;

    CGRect tableViewFrame = containerFrame;
    tableViewFrame.origin.y = yOffsetForContent;
    tableViewFrame.size.height = containerFrame.size.height - yOffsetForContent;

    CGFloat inviteViewHeight = [self.bottomActionContainerView.inviteMessageView
                                computeHeightWithWidth:containerFrame.size.width];

    // Adjust bottom inset to make extra room for the invite view, and remove ex
    UIEdgeInsets tableBottomInset = self.ABTableViewController.tableView.contentInset;
    if ([self shouldDisplayInviteMessageView] && tableBottomInset.bottom < inviteViewHeight) {
        CGFloat adjustOffsetBy;
        if (self.ABTableViewController.isFixedSearchBarActive) {
            adjustOffsetBy = inviteViewHeight;
        } else {
            adjustOffsetBy = inviteViewHeight - MAVESearchBarHeight;
        }
        tableBottomInset.bottom  = adjustOffsetBy;
    }
    if (![self shouldDisplayInviteMessageView]) {
        CGFloat adjustOffsetBy;
        if (self.ABTableViewController.isFixedSearchBarActive) {
            adjustOffsetBy = 0;
        } else {
            adjustOffsetBy = 0 - MAVESearchBarHeight;
        }
        tableBottomInset.bottom = adjustOffsetBy;
    }
    self.ABTableViewController.tableView.contentInset = tableBottomInset;


    // Put the invite message view off bottom of screen unless we should display it,
    // then it goes at the very bottom
    CGFloat inviteViewOffsetY = containerFrame.origin.y + containerFrame.size.height;
    if ([self shouldDisplayInviteMessageView]) {
        inviteViewOffsetY -= inviteViewHeight;
    }
    CGRect inviteMessageViewFrame = CGRectMake(0,
                                               inviteViewOffsetY,
                                               containerFrame.size.width,
                                               inviteViewHeight);

    // If the fixed search bar is active, set the frame and make room for it by shrinking the table
    if (self.ABTableViewController.isFixedSearchBarActive) {
        CGRect fixedSearchBarFrame = CGRectMake(0, yOffsetForContent, containerFrame.size.width, MAVESearchBarHeight);
        self.abTableFixedSearchbar.frame = fixedSearchBarFrame;
        tableViewFrame.origin.y += MAVESearchBarHeight;
        tableViewFrame.size.height -= MAVESearchBarHeight;
    } else {
        self.abTableFixedSearchbar.frame = CGRectMake(0, 0, 0, 0);
    }

    self.view.frame = containerFrame;
    self.ABTableViewController.tableView.frame = tableViewFrame;
    self.ABTableViewController.aboveTableContentView.frame =
        CGRectMake(0,
                   -containerFrame.size.height,
                   containerFrame.size.width,
                   containerFrame.size.height);
    self.bottomActionContainerView.frame = inviteMessageViewFrame;

    // adjust the search table bottom content inset so it doesn't hide results behind
    // the area taken up by keyboard + invite message container view
    CGFloat searchViewOffset = self.keyboardFrame.size.height - self.ABTableViewController.tableView.contentInset.top;
    if ([self shouldDisplayInviteMessageView]) {
        searchViewOffset += self.bottomActionContainerView.frame.size.height;
    }
    self.ABTableViewController.searchTableView.contentInset = UIEdgeInsetsMake(0, 0, searchViewOffset, 0);

    // Resize the header based on width
    [self.ABTableViewController layoutHeaderViewForWidth:containerFrame.size.width];
}
//
// Respond to children's Events
//

- (void)ABTableViewControllerNumberSelectedChanged:(NSUInteger)numberChanged {
    // If called from the table view's "did select row at index path" method we'll already be
    // in the main thread anyway, but dispatch it asynchronously just in case we ever call
    // from somewhere else.
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutInvitePageViewAndSubviews];
        }];
        [self.bottomActionContainerView.inviteMessageView updateNumberPeopleSelected:numberChanged];
    });
}


//
// Send invites and update UI when done
//
- (void)sendInvites {
    NSString *message = self.bottomActionContainerView.inviteMessageView.textView.text;
    NSArray *phonesToInvite = [self.ABTableViewController.selectedPhoneNumbers allObjects];
    NSArray *peopleToInvite = [self.ABTableViewController.selectedPeople allObjects];
    NSInteger numberInvites = [phonesToInvite count];
    if (numberInvites == 0) {
        MAVEDebugLog(@"Pressed Send but no recipients selected");
        return;
    }
    
    MaveSDK *mave = [MaveSDK sharedInstance];
    MAVEAPIInterface *apiInterface = mave.APIInterface;

    [apiInterface sendInvitesWithRecipientPhoneNumbers:phonesToInvite
                               recipientContactRecords:peopleToInvite
                                               message:message
                                                userId:mave.userData.userID
                              inviteLinkDestinationURL:mave.userData.inviteLinkDestinationURL
                                       completionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error != nil) {
            MAVEDebugLog(@"Invites failed to send, error: %@, response: %@",
                  error, responseData);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorAndResetAfterSendInvitesFailure:error];
            });
        } else {
            MAVEInfoLog(@"Sent %d invites!", numberInvites);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bottomActionContainerView.sendingInProgressView completeSendingProgress];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissSelf:(unsigned int)numberInvites];
            });
        }
    }];
    [self.bottomActionContainerView makeSendingInProgressViewActive];
}

- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error {
    [self.bottomActionContainerView makeInviteMessageViewActive];
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

// Do Share sheet invites instead
- (void)presentShareSheet {
    MaveSDK *mave = [MaveSDK sharedInstance];
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    [activityItems addObject:mave.defaultSMSMessageText];
    if ([mave.appId isEqualToString:MAVEPartnerApplicationIDSwig] ||
        [mave.appId isEqualToString:MAVEPartnerApplicationIDSwigEleviter]) {
        [activityItems addObject:[NSURL URLWithString:MAVEInviteURLSwig]];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:activityItems
                                            applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList];

    // completion handler changed in ios8, but the alternative is deprecated in ios8 and gives warnings.
    // So we define a handler compatible with the old format, but wrap it in the new format if the
    // activity view controller responds to the new method
    UIActivityViewControllerCompletionHandler completionHandler = ^void(NSString *activityType, BOOL completed) {
        unsigned int numberShares = completed ? 1 : 0;
        [self dismissSelf:numberShares];
    };
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([activityVC respondsToSelector:@selector(completionWithItemsHandler)]) {
        activityVC.completionWithItemsHandler = ^void(NSString *activityType, BOOL completed,
                                                      NSArray *returnedItems, NSError *activityError) {
            completionHandler(activityType, completed);
        };
    } else {
        activityVC.completionHandler = completionHandler;
    }
#pragma clang diagnostic pop
    [self presentViewController:activityVC animated:YES completion:nil];

    // Tracking event that share sheet was presented
    [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeNativeShareSheet];
}

@end
