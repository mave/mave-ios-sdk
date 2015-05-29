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
#import <MessageUI/MessageUI.h>
#import "MAVEInvitePageViewController.h"
#import "MAVEContactsInvitePageV2ViewController.h"
#import "MAVEContactsInvitePageV3ViewController.h"

typedef void (^MAVEInvitePagePresentBlock)(UIViewController *inviteController);
typedef void (^MAVEInvitePageDismissBlock)(UIViewController *controller, NSUInteger numberOfInvitesSent);

extern NSString * const MAVEInvitePageTypeContactList;
extern NSString * const MAVEInvitePageTypeContactListV2;
extern NSString * const MAVEInvitePageTypeCustomShare;
extern NSString * const MAVEInvitePageTypeNativeShareSheet;

extern NSString * const MAVEInvitePagePresentFormatModal;
extern NSString * const MAVEInvitePagePresentFormatPush;

@interface MAVEInvitePageChooser : NSObject

@property (nonatomic, strong) UIViewController *activeViewController;
@property (nonatomic, assign) BOOL needToUnwindReplacementModalViewController;
- (UINavigationController *)activeNavigationController;
@property (nonatomic, copy) NSString *navigationPresentedFormat;
@property (nonatomic, copy) MAVEInvitePageDismissBlock navigationCancelBlock;
@property (nonatomic, copy) MAVEInvitePageDismissBlock navigationBackBlock;
@property (nonatomic, copy) MAVEInvitePageDismissBlock navigationForwardBlock;

- (instancetype) initForModalPresentWithCancelBlock:(MAVEInvitePageDismissBlock)cancelBlock;
- (instancetype) initForPushPresentWithForwardBlock:(MAVEInvitePageDismissBlock)backBlock
                                       backBlock:(MAVEInvitePageDismissBlock)nextBlock;


// Choose which invite page to present and initialize is view controller
- (UIViewController *)chooseAndCreateInvitePageViewController;
- (MAVEInvitePageViewController *)createContactsInvitePageIfAllowed;
- (MAVEContactsInvitePageV2ViewController *)createContactsInvitePageV2IfAllowed;
- (MAVEContactsInvitePageV3ViewController *)createContactsInvitePageV3IfAllowed;
- (MFMessageComposeViewController *)createClientSMSInvitePage;

// Helpers for business logic
- (BOOL)isAnyServerSideContactsInvitePageAllowed;
- (BOOL)isInSupportedRegionForServerSideSMSInvites;
// TODO: deprecate the following, we can remove this kill switch b/c we can use
// the invite page chooser as the kill switch
- (BOOL)isContactsInvitePageEnabledServerSide;
//
// Handling the changing of view controllers
//

// Navigation bar methods
// This is the entry point, the following are helpers for it
- (void)setupNavigationBarForActiveViewController;
- (void)_embedActiveViewControllerInNewNavigationController;
- (void)_styleNavigationItemForActiveViewController;
- (void)_setupNavigationBarButtonsModalStyle;
- (void)_setupNavigationBarButtonsPushStyle;

// Helper to replace whatever the active controller is with a new share page view controller
- (void)replaceActiveViewControllerWithFallbackPage;
- (void)dismissModalViewControllersAboveBottomIfAny;


- (void)dismissOnSuccess:(NSUInteger)numberOfInvitesSent;
- (void)dismissOnCancel;
- (void)dismissOnBack;
- (void)dismissOnForward;

@end
