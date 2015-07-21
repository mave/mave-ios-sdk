//
//  MAVEContactsInvitePageV3ViewController.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageV3Cell.h"
#import "MAVEInviteTableSectionHeaderView.h"
#import "MAVEContactsInvitePageDataManager.h"
#import "MAVEContactsInvitePageSearchManager.h"
#import "MAVEContactsInvitePageV3TableWrapperView.h"
#import "MAVERemoteConfigurationContactsInvitePage.h"

@interface MAVEContactsInvitePageV3ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// how we'll send the sms invites, server-side or client side
@property (nonatomic, assign) MAVESMSInviteSendMethod inviteSendMethod;

// Keep a weak reference to the wrapper view, which is really just the view
@property (nonatomic, weak) MAVEContactsInvitePageV3TableWrapperView *wrapperView;
// Use an instance of the cell for calculating the height of rows.
@property (nonatomic, strong) MAVEContactsInvitePageV3Cell *sampleCell;
// Keep a reference to the suggestions section, because we put the loading dots in the section
// header when suggested invites are still loading
@property (nonatomic, strong) MAVEInviteTableSectionHeaderView *suggestionsSectionHeaderView;

@property (nonatomic, strong) NSMutableSet *selectedPeopleIndex;
@property (nonatomic, strong) NSMutableSet *selectedContactIdentifiersIndex;
@property (nonatomic, strong) MAVEContactsInvitePageDataManager *dataManager;
@property (nonatomic, strong) MAVEContactsInvitePageSearchManager *searchManager;

- (void)updateToReflectPersonSelectedStatus:(MAVEABPerson *)person;
- (void)selectOrDeselectAll:(BOOL)select;

// Method to send the invites when clicking the button
- (void)sendInvitesToSelected;
- (void)sendRemoteInvitesToSelected;
- (void)sendRemoteInviteToAnonymousContactIdentifier:(MAVEContactIdentifierBase *)contactIdentifier successBlock:(void(^)())successBlock;
- (void)sendClientSideGroupInvitesToSelected;

@end
