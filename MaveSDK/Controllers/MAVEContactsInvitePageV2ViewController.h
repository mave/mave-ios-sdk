//
//  MAVEContactsInvitePageV2ViewController.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"
#import "MAVESearchBar.h"
#import "MAVEContactsInvitePageV2TableWrapperView.h"
#import "MAVEInviteTableSectionHeaderView.h"

@protocol MAVEContactsWithSuggestionsTable <NSObject>

- (void)updateTableData:(NSDictionary *)tableData;
- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites;
- (void)updateTableDataWithoutReloading:(NSDictionary *)tableData;

@end

@interface MAVEContactsInvitePageV2ViewController : UIViewController <UITableViewDataSource, MAVEContactsWithSuggestionsTable, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) MAVEContactsInvitePageV2TableWrapperView *wrapperView;
@property (nonatomic, strong) MAVEInviteTableSectionHeaderView *suggestionsSectionHeaderView;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, strong) NSDictionary *tableData;
@property (nonatomic, strong) NSArray *searchTableData;
@property (nonatomic, strong) NSDictionary *personToIndexPathsIndex;
@property (nonatomic, assign) CGFloat currentKeyboardHeightFromBottom;

- (MAVEABPerson *)tableView:(UITableView *)tableView personForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updatePersonToIndexPathsIndex;
- (NSArray *)enumerateAllContacts;
- (void) jumpToMainTableRowForPerson:(MAVEABPerson *)recipient;

// Helpers for accessing nested objects
- (UITableView *)tableView;
- (UITableView *)searchTableView;
- (UITextView *)messageTextView;
- (MAVESearchBar *)searchBar;

// Send invite methods
- (void)sendInviteToPerson:(MAVEABPerson *)person selectedFromSuggestions:(BOOL)selectedFromSuggestions;
- (void)inviteSentSuccessHandlerPerson:(MAVEABPerson *)recipient waitSema:(dispatch_semaphore_t)sema;
- (void)innerInviteSentSuccessHandlerPerson:(MAVEABPerson *)recipient;

// Keyboard helpers
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification;

@end