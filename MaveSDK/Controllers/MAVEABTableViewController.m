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
#import "MAVEInviteTableSectionHeaderView.h"
#import "MAVEWaitingDotsImageView.h"

// This is UTF-8 code point 0021, it should get sorted before any letters in any language
NSString * const MAVESuggestedInvitesTableDataKey = @"\u2605";
// This is the last UTF-8 printable character, it should get sorted after any letters in any language
NSString * const MAVENonAlphabetNamesTableDataKey = @"\uffee";

@implementation MAVEABTableViewController

#pragma mark - Init and Layout
- (instancetype)initTableViewWithParent:(MAVEInvitePageViewController *)parent {
    if(self = [super init]) {
        MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
        self.parentViewController = parent;
        self.didInitialTableDataLoad = NO;
        self.lockScrollViewDidScroll = NO;
        self.didInitialTableHeaderLayout = NO;
        self.selectedPhoneNumbers = [[NSMutableSet alloc] init];
        self.selectedPeople = [[NSMutableSet alloc] init];

        self.tableView = [[UITableView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = displayOptions.contactCellBackgroundColor;
        self.tableView.separatorColor = displayOptions.contactSeparatorColor;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // don't show cell separators between empty cells
        self.tableView.sectionIndexColor = displayOptions.contactSectionIndexColor;
        self.tableView.sectionIndexBackgroundColor = displayOptions.contactSectionIndexBackgroundColor;
        [self.tableView registerClass:[MAVEABPersonCell class]
               forCellReuseIdentifier:MAVEInvitePageABPersonCellID];
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        [self setupTableHeader];
        [self setupSearchTableView];
        self.suggestedInvitesSectionHeaderView = [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:@"Suggestions" sectionIsWaiting:YES];
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

    self.parentViewController.abTableFixedSearchbar.delegate = self;
    [self.parentViewController.abTableFixedSearchbar addTarget:self
                                                        action:@selector(textFieldDidChange:)
                                              forControlEvents:UIControlEventEditingChanged];

    if (![self.inviteTableHeaderView hasContentOtherThanSearchBar]) {
        self.isFixedSearchBarActive = YES;
    } else {
        self.isFixedSearchBarActive = NO;
    }
}

- (void)setupSearchTableView {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = displayOptions.contactCellBackgroundColor;
    self.searchTableView.separatorColor = displayOptions.contactSeparatorColor;
    self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // don't show cell separators between empty lines
    self.searchTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchTableView registerClass:[MAVEABPersonCell class]
                 forCellReuseIdentifier:MAVEInvitePageABPersonCellID];
}

- (void)layoutHeaderViewForWidth:(CGFloat)width {
    CGRect prevInviteTableHeaderViewFrame = self.inviteTableHeaderView.frame;
    // use ceil so rounding errors won't cause tiny gap below the table header view
    CGFloat inviteTableHeaderViewHeight = ceil([self.inviteTableHeaderView
                                                computeHeightWithWidth:width]);

    CGRect inviteExplanationViewFrame = CGRectMake(0,
                                                   0,
                                                   width,
                                                   inviteTableHeaderViewHeight);

    // table header view needs to be re-assigned when frame changes or the rest
    // of the table doesn't get offset and the header overlaps it
    if (!CGRectEqualToRect(inviteExplanationViewFrame, prevInviteTableHeaderViewFrame)) {
        self.inviteTableHeaderView.frame = inviteExplanationViewFrame;
        self.tableView.tableHeaderView = self.inviteTableHeaderView;

        // match above table color to explanation view color so it looks like one view
        if ([self.inviteTableHeaderView hasContentOtherThanSearchBar]) {
            self.aboveTableContentView.backgroundColor = self.inviteTableHeaderView.backgroundColor;
        }
    }

    // first time we layout the page, if the header view is only a search bar anyway then replace
    // it with the fixed search bar
    if (!self.didInitialTableHeaderLayout) {
        if (![self.inviteTableHeaderView hasContentOtherThanSearchBar]) {
            self.tableView.contentOffset = CGPointMake(0, self.inviteTableHeaderView.searchBar.frame.size.height);
        }
        self.didInitialTableHeaderLayout = YES;
    }
}

- (CGFloat)navigationBarHeight {
    return self.parentViewController.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)tableHeaderEmbeddedSearchBarTopEdge {
    return self.inviteTableHeaderView.frame.size.height - self.inviteTableHeaderView.searchBar.frame.size.height;
}

- (BOOL)isSearchTableVisible {
    return [self.searchTableView isDescendantOfView:self.tableView];
}

# pragma mark - Updating the table data
- (void)updateTableData:(NSDictionary *)data {
    [self updateTableDataWithoutReloading:data];

    // if there are definitely no suggestions, the section won't exist in table data.
    // if section does exist and is empty, it should be pending (which is the default
    // state of the suggestions section header view).
    // if it's not empty, stop the pending dots
    NSArray *suggestions = [data objectForKey:MAVESuggestedInvitesTableDataKey];
    if (suggestions && [suggestions count] != 0) {
        [self.suggestedInvitesSectionHeaderView stopWaiting];
    }
    [self.tableView reloadData];
    self.didInitialTableDataLoad = YES;
}

- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites {
    // Update the table data without telling the table to reload
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:self.tableData];
    if ([suggestedInvites count] == 0) {
        // no suggested invites, remove the section from data source and reload
        [newData removeObjectForKey:MAVESuggestedInvitesTableDataKey];
        [self updateTableData:[NSDictionary dictionaryWithDictionary:newData]];
        return;
    } else {
        // Add the suggested invites to data source before animating them in
        [newData setObject:suggestedInvites forKey:MAVESuggestedInvitesTableDataKey];
        [self updateTableDataWithoutReloading:[NSDictionary dictionaryWithDictionary:newData]];
    }

    // Animate in the new rows
    NSUInteger indexOfSuggested = [self.tableSections indexOfObject:MAVESuggestedInvitesTableDataKey];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[suggestedInvites count]];
    for (NSInteger rowNumber = 0; rowNumber < [suggestedInvites count]; ++rowNumber) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:indexOfSuggested]];
    }

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.suggestedInvitesSectionHeaderView stopWaiting];
}

// This is a helper for places we may want to update table data and animate it in rather than reloading
- (void)updateTableDataWithoutReloading:(NSDictionary *)data {
    self.tableData = data;
    self.tableSections = [[self.tableData allKeys]
                          sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self updatePersonToIndexPathsIndex];
}

// Build a reverse index from people to the index paths they're found at in the table
// The data structure is is an dictionary mapping an NSNumber (person recordID) to an NSArray of
// NSIndexPaths.
// NB: a person can be found at multiple rows in a table which is why we map to an array of index paths
- (void)updatePersonToIndexPathsIndex {
    NSNumber *personKey;
    NSIndexPath *idxPath; NSInteger sectionIdx = 0, rowIdx = 0;
    NSMutableDictionary *index = [[NSMutableDictionary alloc] init];
    for (NSString *sectionKey in self.tableSections) {
        rowIdx = 0;
        for (MAVEABPerson *person in [self.tableData objectForKey:sectionKey]) {
            personKey = [NSNumber numberWithInteger:person.recordID];
            idxPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
            if (![index objectForKey:personKey]) {
                [index setObject:[[NSMutableArray alloc] init] forKey:personKey];
            }
            [[index objectForKey:personKey] addObject:idxPath];
            rowIdx++;
        }
        sectionIdx++;
    }
    self.personToIndexPathsIndex = index;
}

- (MAVEABPerson *)personOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // main table view
    if (tableView == self.tableView) {
        NSString *sectionTitle = [self.tableSections objectAtIndex:indexPath.section];
        return [[self.tableData objectForKey:sectionTitle] objectAtIndex:indexPath.row];
    // search table view
    } else {
        // search results empty
        if ([self.searchedTableData count] == 0) {
            return nil;
        } else {
            return [self.searchedTableData objectAtIndex:indexPath.row];
        }
    }
}

// Returns an array of nsindexpaths, guarenteed to have at least one item in the array.
// If person is not in the table it returns an array with the index path of the top
// of the table
- (NSArray *)indexPathsOnMainTableViewForPerson:(MAVEABPerson *)person {
    NSArray *indexPaths;
    if (person.recordID > 0) {
        NSNumber *recordID = [NSNumber numberWithInteger:person.recordID];
        indexPaths = [self.personToIndexPathsIndex objectForKey:recordID];
    }
    if (!indexPaths || [indexPaths count] == 0) {
        indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    return indexPaths;
}


# pragma mark - Table Sections

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [self.tableSections count];
    }
    else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    if (tableView == self.tableView) {
        NSString *sectionTitleShort = [self.tableSections objectAtIndex:section];
        if (sectionTitleShort == MAVESuggestedInvitesTableDataKey) {
            view = self.suggestedInvitesSectionHeaderView;
        } else {
            view = [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:sectionTitleShort
                                                              sectionIsWaiting:NO];
        }

    } else {
        view = [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:@"Search results"
                                                          sectionIsWaiting:NO];
    }
    return view;
}

// Since we size the headers dynamically based on height of the text
// lable, this method needs to get the actual view and check its height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // this tableView will always be self.tableView
    UIView *header = [self tableView:tableView viewForHeaderInSection:section];
    return header.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    if (tableView == self.tableView) {
        NSString *sectionTitle = [self.tableSections objectAtIndex:section];
        numberOfRows = [[self.tableData objectForKey:sectionTitle] count];
    }
    else {
        numberOfRows = [self.searchedTableData count];
        // if no data, we'll show a "no results" empty cell
        if (numberOfRows == 0) {
            numberOfRows = 1;
        }
    }
    return numberOfRows;
}

# pragma mark - Table index values

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.tableSections;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.tableView) {
        return index;
    } else {
        return -1;
    }
}


# pragma mark - Data Source methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = MAVEInvitePageABPersonCellID;
    MAVEABPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                             forIndexPath:indexPath];
    MAVEABPerson *person = [self personOnTableView:tableView atIndexPath:indexPath];
    if (!person) {
        [cell setupCellForNoPersonFound];
    } else {
        [cell setupCellWithPerson:person];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // choose person clicked on
    MAVEABPerson *person = [self personOnTableView:tableView atIndexPath:indexPath];

    // person might appear in the main table more than once, lookup an array of all index paths
    // for this person
    NSArray *mainTableIndexPaths = [self indexPathsOnMainTableViewForPerson:person];

    // deal with selected state of person
    person.selected = !person.selected;
    if (person.selected) {
        [self.selectedPhoneNumbers addObject:person.bestPhone];
        [self.selectedPeople addObject:person];
    } else {
        [self.selectedPhoneNumbers removeObject:person.bestPhone];
        [self.selectedPeople removeObject:person];
    }
    [self.parentViewController ABTableViewControllerNumberSelectedChanged:[self.selectedPhoneNumbers count]];

    // Tracking events
    MAVEAPIInterface *apiInterface = [MaveSDK sharedInstance].APIInterface;
    if (tableView == self.searchTableView) {
        [apiInterface trackInvitePageSelectedContactFromList:@"contacts_search"];
    } else {
        [apiInterface trackInvitePageSelectedContactFromList:@"contacts"];
    }

    // if selected/un-selected on search table view, switch back to main table view and scroll to the
    // first instance of that person selected, reload row, and clear search bar
    if (tableView == self.searchTableView) {
        NSIndexPath *scrollTo = [mainTableIndexPaths objectAtIndex:0];
        [self removeSearchTableView];
        [self.tableView scrollToRowAtIndexPath:scrollTo
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        self.parentViewController.abTableFixedSearchbar.text = @"";

    }
    [self.tableView reloadRowsAtIndexPaths:mainTableIndexPaths
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.parentViewController layoutInvitePageViewAndSubviews];
}


#pragma mark - Search Results

- (NSArray *)allPersons {
    if (_allPersons) {
        return _allPersons;
    }

    NSMutableArray *mutableAllPeople = [NSMutableArray array];
    NSMutableSet *mutableAllPeopleUnique = [[NSMutableSet alloc] init];
    for (NSArray *section in [self.tableData allValues]) {
        for (MAVEABPerson *person in section) {
            if (![mutableAllPeopleUnique containsObject:person]) {
                [mutableAllPeople addObject:person];
                [mutableAllPeopleUnique addObject:person];
            }
        }
    }

    _allPersons = [NSArray arrayWithArray:mutableAllPeople];
    return _allPersons;
}

- (void)searchContacts:(NSString *)searchText {
    // Modeled after the Contacts app basic search functionality
    //  Search by search terms's fragments using BEGINSWITH (way faster than CONTAINS)
    //  Ex: "Jo G" will match things like "John Graham" or "Josh Graham", but not "Graham"

    if (searchText.length > 0) {
        NSArray *fragments = [searchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:fragments.count];
        for (NSString *fragment in fragments) {
            if ([fragment isEqualToString:@""]) {
                continue;
            }

            // For each fragment in the search text, check that either firstName
            //  or lastName BEGINSWITH that fragment
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:
                                            @"(firstName BEGINSWITH[c] %@) OR (lastName BEGINSWITH[c] %@)",
                                            fragment, fragment];
            [predicates addObject:resultPredicate];
        }

        NSCompoundPredicate *compoundPredicate = [[NSCompoundPredicate alloc]
                                                  initWithType:NSAndPredicateType
                                                  subpredicates:predicates];
        self.searchedTableData = [self.allPersons filteredArrayUsingPredicate:compoundPredicate];
    } else {
        self.searchedTableData = @[];
    }
}

#pragma mark - Arranging search bars and content

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lockScrollViewDidScroll) {
        return;
    }

    //
    // Attach/detach the search bar from the top when scrolling.
    //
    // The whole table view gets moved when this happens to make room for the fixed search bar above it
    // as a sibling view, so we need to counter-adjust:
    //   - the offset so it doesn't look like a jump in scrolling content when this happens
    //   - the inset, so the vertical center of the scroll view's content area stays in the same place
    //        which prevents the table section index from jumping vertically.
    //
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat embeddedSearchBarTop = [self tableHeaderEmbeddedSearchBarTopEdge];
    CGFloat embeddedSearchBarHeight = self.inviteTableHeaderView.searchBar.frame.size.height;
    CGFloat embeddedSearchBarBottom = embeddedSearchBarTop + embeddedSearchBarHeight;

    BOOL shouldMakeSearchBarFixed = !self.isFixedSearchBarActive && offsetY >= embeddedSearchBarTop;
    BOOL shouldMakeSearchBarUnfixed = self.isFixedSearchBarActive && offsetY < embeddedSearchBarBottom;

    if (shouldMakeSearchBarFixed) {
        self.isFixedSearchBarActive = YES;
        CGPoint newOffset = CGPointMake(0, offsetY + embeddedSearchBarHeight);
        UIEdgeInsets newInset = self.tableView.contentInset;
        newInset.bottom += embeddedSearchBarHeight;

        self.lockScrollViewDidScroll = YES;
        [self.parentViewController layoutInvitePageViewAndSubviews];
        self.tableView.contentInset = newInset;
        self.tableView.contentOffset = newOffset;
        self.lockScrollViewDidScroll = NO;

    } else if (shouldMakeSearchBarUnfixed) {
        self.isFixedSearchBarActive = NO;
        CGPoint newOffset = self.tableView.contentOffset;
        newOffset.y -= embeddedSearchBarHeight;
        UIEdgeInsets newInset = self.tableView.contentInset;
        newInset.bottom -= embeddedSearchBarHeight;

        self.lockScrollViewDidScroll = YES;
        [self.parentViewController layoutInvitePageViewAndSubviews];
        self.tableView.contentInset = newInset;
        self.tableView.contentOffset = newOffset;
        self.lockScrollViewDidScroll = NO;
    }

    //
    // re-layout the invite header view if it's not just the search bar to keep it centered
    //
    if ([self.inviteTableHeaderView hasContentOtherThanSearchBar] && offsetY < 0) {
        [self.inviteTableHeaderView resizeWithShiftedOffsetY:offsetY];
    }
}

#pragma mark - Search TableView management

- (BOOL)textFieldShouldBeginEditing:(UITextField *)searchBar {
    if (searchBar == self.inviteTableHeaderView.searchBar) {
        [self transitionHeaderSearchBarToRealSearchBar];
        return NO;
    }
    return YES;
}

- (void)transitionHeaderSearchBarToRealSearchBar {
    CGPoint newOffset = CGPointMake(0, [self tableHeaderEmbeddedSearchBarTopEdge]);
    [self.tableView setContentOffset:newOffset animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.parentViewController.abTableFixedSearchbar becomeFirstResponder];
    });
}

- (void)textFieldDidChange:(UITextField *)textField  {
    // This will always be the fixed search bar, text is not editable
    // in the search bar at the botton of the table header
    if (![textField isEqual: self.parentViewController.abTableFixedSearchbar]) {
        return;
    }

    NSString *searchText = textField.text;
    [self searchContacts:searchText];
    [self.searchTableView reloadData];

    if ([searchText isEqualToString:@""]) {
        [self removeSearchTableView];

    } else if (![self isSearchTableVisible]) {
        [self addSearchTableView];
    }
}

- (void)addSearchTableView {
    // The index shows above all other subviews, make clear to hide while searching
    self.tableView.sectionIndexColor = [UIColor clearColor];

    self.searchTableView.frame = self.tableView.frame;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.parentViewController.view addSubview:self.searchTableView];
}

- (void)removeSearchTableView {
    // re-show section index titles
    self.tableView.sectionIndexColor = [MaveSDK sharedInstance].displayOptions.contactSectionIndexColor;
    [self.searchTableView removeFromSuperview];
    self.tableView.scrollEnabled = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self removeSearchTableView];
    [self.parentViewController.abTableFixedSearchbar resignFirstResponder];
}

// Even though there's no cancel or done button, this gets triggered when user starts scrolling
// away while text is still in text field
- (void)textFieldDidEndEditing:(UITextField *)searchBar {
    self.parentViewController.abTableFixedSearchbar.text = @"";
}


@end
