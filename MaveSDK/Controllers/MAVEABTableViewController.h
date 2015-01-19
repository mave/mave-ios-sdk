//
//  MAVEABTableViewController.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEInviteTableHeaderView.h"
#import "MAVESearchBar.h"
#import "MAVEABPerson.h"

// This view controller can alert an additional delegate when the number of people selected changes
@protocol MAVEABTableViewAdditionalDelegate <NSObject>
@required
- (void)ABTableViewControllerNumberSelectedChanged:(unsigned long)num;
@end

@interface MAVEABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) UIViewController<MAVEABTableViewAdditionalDelegate> *parentViewController;
@property (nonatomic, strong) MAVEInviteTableHeaderView *inviteTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *aboveTableContentView;
@property (nonatomic, assign) CGFloat contentInsetTopWithoutSearch;
@property (nonatomic, strong) NSMutableSet *selectedPhoneNumbers;
@property (atomic, strong) NSDictionary *personToIndexPathIndex;

// Different forms of table data
@property (nonatomic, strong) NSDictionary *tableData;
@property (nonatomic, strong) NSArray *allPersons;
@property (nonatomic, strong) NSArray *searchedTableData;
@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, strong) NSDictionary *recordIDsToindexPaths;

// For searching
@property (nonatomic, strong) MAVESearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchTableView;

- (instancetype)initTableViewWithParent:(UIViewController<MAVEABTableViewAdditionalDelegate> *)parent;

// constants for determining layout sizes
// height of navigation bar currently
- (CGFloat)navigationBarHeight;
// y-coordinate of the fixed search bar (just below navigation bar)
- (CGFloat)fixedSearchBarYCoord;
// threshold for when the table header with its "fake" search bar & the above
// table content is visible. If main table view contentOffset is less than this,
// it's visible, otherwise just the body of the table with the fixed search bar
// is visible.
- (CGFloat)showingTableHeaderOffsetThreshold;

- (void)updateTableData:(NSDictionary *)data;
- (void)updatePersonToIndexPathIndex;
- (MAVEABPerson *)personOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOnMainTableViewForPerson:(MAVEABPerson *)person;
- (void)layoutHeaderViewForWidth:(CGFloat)width;
- (BOOL)isSearchTableVisible;

// add an additional ui text field delegate field, by monitoring an event
- (void)textFieldDidChange:(UITextField *)textField;

// For searching
- (void)searchContacts:(NSString *)searchText;

@end