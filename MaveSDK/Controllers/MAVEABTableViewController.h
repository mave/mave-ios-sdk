//
//  MAVEABTableViewController.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEInviteTableHeaderView.h"
#import "MAVEInviteTableSectionHeaderView.h"
#import "MAVESearchBar.h"
#import "MAVEABPerson.h"

@class MAVEInvitePageViewController;

// This is the key to use in the table data dict for the suggested invites section.
// It's set to ! which is the first non-whitespace ascii character so it always gets
// sorted to the top of the list, and it won't be used as the first letter in a name
// because all non-letters are mapped to the "#" sections.
extern NSString * const MAVESuggestedInvitesTableDataKey;

@interface MAVEABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) MAVEInvitePageViewController *parentViewController;
@property (nonatomic, strong) MAVEInviteTableHeaderView *inviteTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *aboveTableContentView;
@property (nonatomic, strong) MAVEInviteTableSectionHeaderView *suggestedInvitesSectionHeaderView;
@property (nonatomic, assign) CGFloat contentInsetTopWithoutSearch;
// We store the selected number in addition to the person record to make sure we
// send the invite to the number on the person record that the user intended
@property (nonatomic, strong) NSMutableSet *selectedPhoneNumbers;
@property (nonatomic, strong) NSMutableSet *selectedPeople;
@property (atomic, strong) NSDictionary *personToIndexPathsIndex;

// Different forms of table data
@property (nonatomic, strong) NSDictionary *tableData;
@property (nonatomic, assign) BOOL didInitialTableDataLoad;
@property (nonatomic, strong) NSArray *allPersons;
@property (nonatomic, strong) NSArray *searchedTableData;
@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, strong) NSDictionary *recordIDsToindexPaths;

// For searching
@property (nonatomic, assign) BOOL isFixedSearchBarActive;
@property (nonatomic, assign) BOOL lockScrollViewDidScroll;
@property (nonatomic, assign) BOOL didInitialTableHeaderLayout;
@property (nonatomic, assign) BOOL didInitialViewDidScroll;
@property (nonatomic, strong) UITableView *searchTableView;

- (instancetype)initTableViewWithParent:(MAVEInvitePageViewController *)parent;

// Helper to create the table section header

// constants for determining layout sizes
// height of navigation bar currently
- (CGFloat)navigationBarHeight;
// Value of origin.y for the "fake" search bar that's embedded in the table header,
// this is the point to scroll to to switch over to the fixed real search bar.
// Note that if scrolling with the fixed search bar already active above the table,
// the point where it gets unfixed is the bottom of the search bar so it's this value
// plus the search bar height
- (CGFloat)tableHeaderEmbeddedSearchBarTopEdge;

- (void)updateTableData:(NSDictionary *)data;
- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites;
- (void)updatePersonToIndexPathsIndex;
- (MAVEABPerson *)personOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)indexPathsOnMainTableViewForPerson:(MAVEABPerson *)person;
- (void)layoutHeaderViewForWidth:(CGFloat)width;

- (BOOL)isSearchTableVisible;

// add an additional ui text field delegate field, by monitoring an event
- (void)textFieldDidChange:(UITextField *)textField;

// For searching
+ (NSArray *)searchContacts:(NSArray *)contactsList withText:(NSString *)searchText;

@end
