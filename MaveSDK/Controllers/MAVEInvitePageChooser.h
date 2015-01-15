//
//  MAVEInvitePageChooser.h
//  MaveSDK
//
//  Class in charge of choosing which invite page to display and presenting/coordinating
//  the navigation controllers.
//
//  Decides based on remote-configured options, current address book permissions,
//  device's country, etc.
//
//  Created by Danny Cosson on 1/8/15.
//

#import <UIKit/UIKit.h>

typedef void (^MAVEInvitePagePresentBlock)(UIViewController *inviteController);
typedef void (^MAVEInvitePageDismissBlock)(UIViewController *controller, NSUInteger numberOfInvitesSent);

extern NSString * const MAVEInvitePageTypeContactList;
extern NSString * const MAVEInvitePageTypeCustomShare;
extern NSString * const MAVEInvitePageTypeNativeShareSheet;

extern NSString * const MAVEInvitePagePresentFormatModal;
extern NSString * const MAVEInvitePagePresentFormatPush;

@interface MAVEInvitePageChooser : NSObject

@property (nonatomic, strong) UIViewController *activeViewController;
- (UINavigationController *)activeNavigationController;
@property (nonatomic, copy) NSString *navigationPresentedFormat;
@property (nonatomic, copy) MAVEInvitePageDismissBlock navigationCancelBlock;
@property (nonatomic, copy) MAVEInvitePageDismissBlock navigationBackBlock;
@property (nonatomic, copy) MAVEInvitePageDismissBlock navigationForwardBlock;

- (instancetype) initForModalPresentWithCancelBlock:(MAVEInvitePageDismissBlock)cancelBlock;
- (instancetype) initForPushPresentWithBackBlock:(MAVEInvitePageDismissBlock)backBlock
                                       nextBlock:(MAVEInvitePageDismissBlock)nextBlock;


// Choose which invite page to present and initialize is view controller
- (UIViewController *)chooseAndCreateInvitePageViewController;

// Helpers for business logic
- (BOOL)isInSupportedRegionForServerSideSMSInvites;
- (BOOL)isContactsInvitePageEnabledServerSide;

// Create custom view controllers
- (UIViewController *)createAddressBookInvitePage;
- (UIViewController *)createCustomShareInvitePage;

//
// Handling the changing of view controllers
//

// Alter view controllers
- (UINavigationController *)embedInNavigationController:(UIViewController *)viewController;
- (void)setupNavigationBar:(UIViewController *)viewController
       leftBarButtonTarget:(id)target
       leftBarButtonAction:(SEL)action;


// older method for setting up navigation bar
- (void)setupNavigationBar:(UIViewController *)viewController;

// Navigation bar methods
// This is the entry point, the following are helpers for it
- (void)setupNavigationBarForActiveViewController;
- (void)_embedActiveViewControllerInNewNavigationController;
- (void)_styleNavigationItemForActiveViewController;
- (void)_setupNavigationBarButtonsModalStyle;
- (void)_setupNavigationBarButtonsPushStyle;

// Helper to replace whatever the active controller is with a new share page view controller
- (void)replaceActiveViewControllerWithSharePage;

- (void)handleCancelAction;
- (void)handleBackAction;
- (void)handleForwardAction;

@end
