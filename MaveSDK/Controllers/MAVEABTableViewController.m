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

@implementation MAVEABTableViewController {
    NSDictionary *tableData;
    NSArray *tableSections;
    NSDictionary *recordIDsToindexPaths;
}

#pragma mark - Init and Layout
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
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // don't show cell separators between empty cells
        self.tableView.sectionIndexColor = displayOptions.contactSectionIndexColor;
        self.tableView.sectionIndexBackgroundColor = displayOptions.contactSectionIndexBackgroundColor;
        [self.tableView registerClass:[MAVEABPersonCell class]
               forCellReuseIdentifier:MAVEInvitePageABPersonCellID];
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        [self setupTableHeader];
        [self setupSearchTableView];
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

    self.searchBar = [[MAVESearchBar alloc] init];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;
    self.searchBar.frame = self.inviteTableHeaderView.searchBar.frame;
    [self.searchBar addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];

    [self.tableView addSubview:self.searchBar];
}

- (void)setupSearchTableView {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = displayOptions.contactCellBackgroundColor;
    self.searchTableView.separatorColor = displayOptions.contactSeparatorColor;
    self.searchTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                             UIViewAutoresizingFlexibleHeight);
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

- (CGFloat)navigationBarHeight {
    return self.parentViewController.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)fixedSearchBarYCoord {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    return statusBarHeight + self.navigationBarHeight;
}


- (CGFloat)showingTableHeaderOffsetThreshold {
    return self.inviteTableHeaderView.frame.size.height - [self fixedSearchBarYCoord] - MAVESearchBarHeight;
}

# pragma mark - Updating the table data
- (void)updateTableData:(NSDictionary *)data {
    tableData = data;
    tableSections = [[tableData allKeys]
                     sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self updatePersontoIndexPathIndex];

    [self.tableView reloadData];

    if (self.isSearching) {
        [self searchContacts:self.inviteTableHeaderView.searchBar.text];
        [self.searchTableView reloadData];
    }
}

- (void)updatePersontoIndexPathIndex {
    NSInteger sectionIdx = 0, rowIdx = 0;
    NSMutableDictionary *index = [[NSMutableDictionary alloc] init];
    for (NSString *key in tableSections) {
        rowIdx = 0;
        for (MAVEABPerson *person in [tableData objectForKey:key]) {
            [index setObject:[NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx]
                      forKey:[NSNumber numberWithInteger:person.recordID]];
            rowIdx++;
        }
        sectionIdx++;
    }
    self.personToIndexPathIndex = index;
}

- (MAVEABPerson *)personOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // main table view
    if (tableView == self.tableView) {
        NSString *sectionTitle = [tableSections objectAtIndex:indexPath.section];
        return [[tableData objectForKey:sectionTitle] objectAtIndex:indexPath.row];
        // search table view
    } else {
        return [self.searchedTableData objectAtIndex:indexPath.row];
    }
}

- (NSIndexPath *)indexPathOnMainTableViewForPerson:(MAVEABPerson *)person {
    NSIndexPath *indexPath;
    if (person.recordID > 0) {
        NSNumber *recordID = [NSNumber numberWithInteger:person.recordID];
        indexPath = [self.personToIndexPathIndex objectForKey:recordID];
    }
    if (!indexPath) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return indexPath;
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

    if (tableView == self.tableView) {
        // When scrolling up through the table index, when a given header is at the top of the screen (e.g. "M")
        // the header before it (e.g. "L") gets rendered onto the view just above the offset at the very front of
        // the view stack so it's visible over the text bar.
        // As a workaround, whenever we return a view for a header we move the search bar to the front on a
        // very small delay. There may be a flash on the screen but it's a relatively edge case scenario anyway
        // so it's acceptable for now.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView bringSubviewToFront:self.searchBar];
        });
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [tableSections objectAtIndex:section];
    } else {
        return @"Search results";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSString *sectionTitle = [tableSections objectAtIndex:section];
        return [[tableData objectForKey:sectionTitle] count];
    }
    else {
        return [self.searchedTableData count];
    }
}

//
// Data Source methods
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = MAVEInvitePageABPersonCellID;
    MAVEABPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                             forIndexPath:indexPath];
    MAVEABPerson *person = [self personOnTableView:tableView atIndexPath:indexPath];
    [cell setupCellWithPerson:person];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // choose person clicked on
    MAVEABPerson *person = [self personOnTableView:tableView atIndexPath:indexPath];

    // deal with selected state of person
    person.selected = !person.selected;
    if (person.selected) {
        [self.selectedPhoneNumbers addObject:person.bestPhone];
    } else {
        [self.selectedPhoneNumbers removeObject:person.bestPhone];
    }
    [self.parentViewController ABTableViewControllerNumberSelectedChanged:[self.selectedPhoneNumbers count]];

    // if selected/un-selected on search table view, switch back to main table view with person selected
    // (and reload row)
    if (tableView == self.searchTableView) {
        NSIndexPath *mainTableIndex = [self indexPathOnMainTableViewForPerson:person];
        [self removeSearchTableView];
        [self.tableView scrollToRowAtIndexPath:mainTableIndex
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        [self.tableView reloadRowsAtIndexPaths:@[mainTableIndex]
                              withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return tableSections;
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
    CGFloat offsetY = self.tableView.contentOffset.y;
    NSLog(@"Offset in scroll: %f", offsetY);

    // Scrolled above search bar
    if (offsetY < [self showingTableHeaderOffsetThreshold]) {

        // Vertically center the text above the table
        CGFloat shiftedOffsetY = offsetY + self.tableView.contentInset.top;
        [self.inviteTableHeaderView resizeWithShiftedOffsetY:shiftedOffsetY];

        self.inviteTableHeaderView.searchBar.hidden = NO;
        self.searchBar.hidden = YES;
    } else {
        // Offset the searchBar while scrolling below the headerView
        CGRect newFrame = self.searchBar.frame;
        newFrame.origin.y = offsetY + [self fixedSearchBarYCoord];
        self.searchBar.frame = newFrame;

        // Hide the inviteTableHeaderView's search bar
        self.inviteTableHeaderView.searchBar.hidden = YES;
        self.searchBar.hidden = NO;
    }
}


#pragma mark - Search TableView management

- (BOOL)textFieldShouldBeginEditing:(UITextField *)searchBar {
    if (searchBar == self.inviteTableHeaderView.searchBar) {
        [self transitionHeaderSearchBarToRealSearchBar];
        return NO;
    } else {
        // Strange hack, enabling editing on the fixed search bar at the top of the table view
        // causes the table view to scroll the distance of the top inset for no apparent reason.
        // So we disable it then enable it after field becomes editable
        self.tableView.scrollEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.scrollEnabled = YES;
        });
    }
    return YES;
}

- (void)transitionHeaderSearchBarToRealSearchBar {
    self.searchBar.frame = self.inviteTableHeaderView.searchBar.frame;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView setContentOffset:CGPointMake(0, [self showingTableHeaderOffsetThreshold])
                                animated:NO];
    }];
}

- (void)textFieldDidChange:(UITextField *)textField  {
    // This will always be the fixed search bar, text is not editable in the search bar at the botton
    // of the table header

    NSString *searchText = textField.text;
    [self searchContacts:searchText];
    [self.searchTableView reloadData];

    // keep text up-to-date with table header
    self.inviteTableHeaderView.searchBar.text = searchText;

    if ([searchText isEqualToString:@""]) {
        self.tableView.sectionIndexColor = [MaveSDK sharedInstance].displayOptions.contactSectionIndexColor; // reshow section index titles
        [self removeSearchTableView];
    } else if (![self.searchTableView isDescendantOfView:self.tableView]) {
        // Checks if the searchTableView a subview of self.tableView (is it being displayed)

        // For some reason, index titles show *above* all other subviews...
        //  Make them clear in order to "hide" while searching
        self.tableView.sectionIndexColor = [UIColor clearColor];
        [self addSearchTableView];
    }
}

- (void)addSearchTableView {
    CGRect searchTableViewFrame = self.tableView.frame;
    searchTableViewFrame.origin.y = self.searchBar.frame.origin.y + MAVE_DEFAULT_SEARCH_BAR_HEIGHT;
    searchTableViewFrame.size.height = 350;
    self.searchTableView.frame = searchTableViewFrame;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.tableView addSubview:self.searchTableView];
}

- (void)removeSearchTableView {
    // re-show section index titles
    self.tableView.sectionIndexColor = [MaveSDK sharedInstance].displayOptions.contactSectionIndexColor;
    [self.searchTableView removeFromSuperview];
    self.tableView.scrollEnabled = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self removeSearchTableView];
    [self.searchBar resignFirstResponder];
}

// Even though there's no cancel or done button, this gets triggered when user starts scrolling
// away while text is still in text field
- (void)textFieldDidEndEditing:(UITextField *)searchBar {
    self.searchBar.text = @"";
    self.inviteTableHeaderView.searchBar.text = @"";
//    [self searchContacts:self.searchBar.text];
//
//    self.isSearching = NO;
////    self.tableView.scrollEnabled = YES;
//    [self.tableView bringSubviewToFront:self.searchBar];
}


@end
