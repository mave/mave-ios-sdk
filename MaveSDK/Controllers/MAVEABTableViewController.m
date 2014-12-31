//
//  MAVEABTableViewController.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MaveSDK.h"
#import "MAVEDisplayOptions.h"
#import "MAVEABTableViewController.h"
#import "MAVEABTableViewController.h"
#import "MAVEInviteTableHeaderView.h"
#import "MAVEInviteExplanationView.h"
#import "MAVEABUtils.h"
#import "MAVEABPersonCell.h"
#import "MAVEABPerson.h"

#define MAVE_AB_TABLE_STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define MAVE_AB_TABLE_NAVIGATION_BAR_HEIGHT self.parentViewController.navigationController.navigationBar.frame.size.height

#define MAVE_AB_TABLE_SEARCH_BAR_Y (MAVE_AB_TABLE_STATUS_BAR_HEIGHT + MAVE_AB_TABLE_NAVIGATION_BAR_HEIGHT)
#define MAVE_AB_TABLE_OFFSET_THRESHOLD_Y (self.inviteTableHeaderView.frame.size.height - MAVE_AB_TABLE_SEARCH_BAR_Y - MAVE_DEFAULT_SEARCH_BAR_HEIGHT)

@interface MAVEABTableViewController ()

@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UIButton *searchBackgroundButton;

@end

@implementation MAVEABTableViewController {
    NSDictionary *tableData;
    NSArray *tableSections;

    NSArray *searchedTableData;
}

- (instancetype)initTableViewWithParent:(UIViewController<MAVEABTableViewAdditionalDelegate> *)parent {
    if(self = [super init]) {
        MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
        self.parentViewController = parent;
        self.selectedPhoneNumbers = [[NSMutableSet alloc] init];

        self.tableView = [[UITableView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = displayOptions.contactCellBackgroundColor;
        self.tableView.separatorColor = displayOptions.contactSeparatorColor;
        self.tableView.sectionIndexColor = displayOptions.contactSectionIndexColor;
        self.tableView.sectionIndexBackgroundColor =
            displayOptions.contactSectionIndexBackgroundColor;
        [self.tableView registerClass:[MAVEABPersonCell class]
               forCellReuseIdentifier:MAVEInvitePageABPersonCellID];
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        [self setupTableHeader];
    }
    return self;
}

- (void)setupTableHeader {
    // default above table content view matches table, it will get overridden to
    // match the above table header view if we add one
    self.aboveTableContentView = [[UIView alloc] init];
    self.aboveTableContentView.backgroundColor = self.tableView.backgroundColor;
    [self.tableView addSubview:self.aboveTableContentView];

    // Set up the header view
    self.inviteTableHeaderView = [[MAVEInviteTableHeaderView alloc] init];
    self.inviteTableHeaderView.searchBar.delegate = self;
    self.inviteTableHeaderView.searchBar.hidden = NO;
    self.tableView.tableHeaderView = self.inviteTableHeaderView;

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;
    CGRect searchBarFrame = self.searchBar.frame;
    searchBarFrame.size = self.inviteTableHeaderView.searchBar.frame.size;
    searchBarFrame.origin = CGPointMake(0, 0);
    self.searchBar.frame = searchBarFrame;
    self.searchBar.hidden = YES;

    [self.tableView addSubview:self.searchBar];
}

- (void)setupSearchTableView {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5]; //displayOptions.contactCellBackgroundColor;
    self.searchTableView.separatorColor = displayOptions.contactSeparatorColor;
    self.searchTableView.sectionIndexColor = displayOptions.contactSectionIndexColor;
    self.searchTableView.sectionIndexBackgroundColor = displayOptions.contactSectionIndexBackgroundColor;
    [self.tableView registerClass:[MAVEABPersonCell class]
           forCellReuseIdentifier:MAVEInvitePageABPersonCellID];
}

- (void)updateTableData:(NSDictionary *)data {
    tableData = data;
    tableSections = [[tableData allKeys]
                     sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];

    if (self.isSearching) {
        [self searchContacts:self.inviteTableHeaderView.searchBar.text];
        [self.searchTableView reloadData];
    }
}

//
// Sections
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [tableSections count];
    }
    else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        CGFloat labelMarginY = 0.0;
        CGFloat labelOffsetX = 14.0;
        MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;
        NSString *labelText = [self tableView:tableView
                      titleForHeaderInSection:section];
        UIFont *labelFont = displayOpts.contactSectionHeaderFont;
        CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName: labelFont}];
        CGRect labelFrame = CGRectMake(labelOffsetX,
                                       labelMarginY,
                                       labelSize.width,
                                       labelSize.height);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = labelText;
        label.textColor = displayOpts.contactSectionHeaderTextColor;
        label.font = labelFont;

        CGFloat sectionHeight = labelMarginY * 2 + label.frame.size.height;
        // section width gets ignored, always stretches to full width
        CGFloat sectionWidth = 0.0;
        CGRect viewFrame = CGRectMake(0, 0, sectionWidth, sectionHeight);
        UIView *view = [[UIView alloc] initWithFrame:viewFrame];
        view.backgroundColor = displayOpts.contactSectionHeaderBackgroundColor;
        
        [view addSubview:label];
        
        return view;
    }
    return nil;
}

// Since we size the headers dynamically based on height of the text
// lable, this method needs to get the actual view and check its height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // this tableView will always be self.tableView
    UIView *header = [self tableView:tableView viewForHeaderInSection:section];
    return header.frame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // this tableView will always be self.tableView
    return [tableSections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSString *sectionTitle = [tableSections objectAtIndex:section];
        return [[tableData objectForKey:sectionTitle] count];
    }
    else {
        return [searchedTableData count];
    }
}

//
// Data Source methods
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = MAVEInvitePageABPersonCellID;
    MAVEABPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                             forIndexPath:indexPath];

    [cell setupCellWithPerson:[self personOnTableView:tableView atIndexPath:indexPath]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *person = [self personOnTableView:tableView atIndexPath:indexPath];
    person.selected = !person.selected;
    if (person.selected) {
        [self.selectedPhoneNumbers addObject:person.bestPhone];
    } else {
        [self.selectedPhoneNumbers removeObject:person.bestPhone];
    }
    [self.parentViewController ABTableViewControllerNumberSelectedChanged:[self.selectedPhoneNumbers count]];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    if (tableView == self.searchTableView) {
        // if a row was selected in the searchTableView, then reload the main tableView so the same
        // row appears tapped as well
        [self.tableView reloadData];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return tableSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

// Scroll delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = self.tableView.contentOffset.y;

    // Scrolled above search bar
    if (offsetY < MAVE_AB_TABLE_OFFSET_THRESHOLD_Y) {
//        UIEdgeInsets contentInset = self.tableView.contentInset;
//        contentInset.top = MAVE_AB_TABLE_SEARCH_BAR_Y;
//        self.tableView.contentInset = contentInset;

        // "Center" the text in the inviteTableHeaderView
        CGFloat shiftedOffsetY = offsetY + self.tableView.contentInset.top;
        [self.inviteTableHeaderView resizeWithShiftedOffsetY:shiftedOffsetY];

        self.inviteTableHeaderView.searchBar.hidden = NO;
        self.searchBar.hidden = YES;
    }
    else {
//        // Move content below the searchBar
//        UIEdgeInsets contentInset = self.tableView.contentInset;
//        contentInset.top = MAVE_AB_TABLE_SEARCH_BAR_Y + MAVE_DEFAULT_SEARCH_BAR_HEIGHT;
//        self.tableView.contentInset = contentInset;

        // Offset the searchBar while scrolling below the headerView
        CGRect newFrame = self.searchBar.frame;
        newFrame.origin.y = offsetY + MAVE_AB_TABLE_SEARCH_BAR_Y;
        self.searchBar.frame = newFrame;

        // Hide the inviteTableHeaderView's search bar
        self.inviteTableHeaderView.searchBar.hidden = YES;
        self.searchBar.hidden = NO;
        [self.tableView bringSubviewToFront:self.searchBar];
    }
}

#pragma mark - Helpers

- (MAVEABPerson *)personOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // TODO unit test
    if (tableView == self.searchTableView) {
        return [searchedTableData objectAtIndex:indexPath.row];
    } else {
        NSString *sectionTitle = [tableSections objectAtIndex:indexPath.section];
        return [[tableData objectForKey:sectionTitle] objectAtIndex:indexPath.row];
    }
}

#pragma mark - Layout

- (void)layoutHeaderViewForWidth:(CGFloat)width {
    CGRect prevInviteTableHeaderViewFrame = self.inviteTableHeaderView.frame;
    // use ceil so rounding errors won't cause tiny gap below the table header view
    CGFloat inviteTableHeaderViewHeight = ceil([self.inviteTableHeaderView
                                                computeHeightWithWidth:width]);
    CGRect inviteExplanationViewFrame = CGRectMake(0, 0, width, inviteTableHeaderViewHeight);

    // table header view needs to be re-assigned when frame changes or the rest
    // of the table doesn't get offset and the header overlaps it
    if (!CGRectEqualToRect(inviteExplanationViewFrame, prevInviteTableHeaderViewFrame)) {
        self.inviteTableHeaderView.frame = inviteExplanationViewFrame;
        self.tableView.tableHeaderView = self.inviteTableHeaderView;

        // match above table color to explanation view color so it looks like one view
        if (self.inviteTableHeaderView.showsExplanation) {
            self.aboveTableContentView.backgroundColor = self.inviteTableHeaderView.backgroundColor;
        }
    }
}

#pragma mark - Search Results

- (NSArray *)allPersons {
    if (_allPersons) {
        return _allPersons;
    }

    NSMutableArray *mutableAllPeople = [NSMutableArray array];

    for (NSArray *section in [tableData allValues]) {
        [mutableAllPeople addObjectsFromArray:section];
    }

    _allPersons = [NSArray arrayWithArray:mutableAllPeople];
    return _allPersons;
}

- (void)searchContacts:(NSString *)searchText {
    if (searchText.length > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:
                                        @"(firstName BEGINSWITH[c] %@) OR (lastName BEGINSWITH[c] %@)",
                                        searchText, searchText];
        searchedTableData = [self.allPersons filteredArrayUsingPredicate:resultPredicate];
    } else {
        searchedTableData = @[];
    }
}

#pragma mark - Search TableView management

- (UIView *)searchBackgroundButton {
    if (!_searchBackgroundButton) {
        _searchBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBackgroundButton.frame = self.tableView.frame;
        _searchBackgroundButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _searchBackgroundButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                                    UIViewAutoresizingFlexibleWidth);
        [_searchBackgroundButton addTarget:self.searchBar action:@selector(resignFirstResponder)
                          forControlEvents:UIControlEventTouchUpInside];
    }

    return _searchBackgroundButton;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.inviteTableHeaderView.searchBar) {
        self.inviteTableHeaderView.searchBar.hidden = YES;
        self.searchBar.hidden = NO;
        [self beginSearchBarEditing];
        return NO;
    }

    [self addSearchBackgroundButton];
    return YES;
}

- (void)beginSearchBarEditing {
    CGFloat offsetY = self.tableView.contentOffset.y;

    if (offsetY < MAVE_AB_TABLE_OFFSET_THRESHOLD_Y) {
        [self.tableView setContentOffset:CGPointMake(0, MAVE_AB_TABLE_OFFSET_THRESHOLD_Y)
                                animated:YES];
    }

    self.isSearching = YES;
    [self.searchBar becomeFirstResponder];
}

- (void)addSearchBackgroundButton {
    CGRect searchBackgroundButtonFrame = self.searchBackgroundButton.frame;
    searchBackgroundButtonFrame.size = self.tableView.frame.size;
    searchBackgroundButtonFrame.origin.y = self.searchBar.frame.origin.y;
    self.searchBackgroundButton.frame = searchBackgroundButtonFrame;

    self.searchBackgroundButton.alpha = 0;
    [self.tableView addSubview:self.searchBackgroundButton];
    [UIView animateWithDuration:.3 animations:^{
        self.searchBackgroundButton.alpha = .5;
    }];

    self.tableView.scrollEnabled = NO;
    [self.tableView bringSubviewToFront:self.searchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearching = NO;
    self.tableView.scrollEnabled = YES;

    [UIView animateWithDuration:.3 animations:^{
        self.searchBackgroundButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.searchBackgroundButton removeFromSuperview];
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchContacts:searchText];
}

@end
