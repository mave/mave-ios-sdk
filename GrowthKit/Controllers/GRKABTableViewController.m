//
//  GRKABTableViewController.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "GrowthKit.h"
#import "GRKDisplayOptions.h"
#import "GRKInvitePageViewController.h"
#import "GRKABTableViewController.h"
#import "GRKABCollection.h"
#import "GRKABPersonCell.h"
#import "GRKABPerson.h"

@interface GRKABTableViewController ()

@end

@implementation GRKABTableViewController {
    NSDictionary *tableData;
    NSArray *tableSections;
}

- (instancetype)initTableViewWithFrame:(CGRect)frame parent:(GRKInvitePageViewController *)parent {
    if(self = [super init]) {
        self.parentViewController = parent;
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorColor = [GrowthKit sharedInstance].displayOptions.borderColor;
        [self.tableView registerClass:[GRKABPersonCell class] forCellReuseIdentifier:@"InvitePageABPersonCell"];
        self.selectedPhoneNumbers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void) updateTableData:(NSDictionary *)data {
    tableData = data;
    tableSections = [[tableData allKeys]
                       sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
}

//
// Sections
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableSections count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float labelMarginY = 0.0;
    float labelOffsetX = 14.0;
    GRKDisplayOptions *displayOpts = [GrowthKit sharedInstance].displayOptions;
    NSString *labelText = [self tableView:tableView
                  titleForHeaderInSection:section];
    UIFont *labelFont = displayOpts.primaryFont;
    CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName: labelFont}];
    CGRect labelFrame = CGRectMake(labelOffsetX,
                                   labelMarginY,
                                   labelSize.width,
                                   labelSize.height);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = labelText;
    label.textColor = displayOpts.primaryTextColor;
    label.font = displayOpts.primaryFont;

    CGFloat sectionHeight = labelMarginY * 2 + label.frame.size.height;
    // section width gets ignored, always stretches to full width
    CGFloat sectionWidth = 0.0;
    CGRect viewFrame = CGRectMake(0, 0, sectionWidth, sectionHeight);
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    view.backgroundColor = displayOpts.tableSectionHeaderBackgroundColor;

    [view addSubview:label];

    return view;
}

// Since we size the headers dynamically based on height of the text
// lable, this method needs to get the actual view and check its height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *header = [self tableView:tableView viewForHeaderInSection:section];
    return header.frame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [tableSections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = [tableSections objectAtIndex:section];
    return [[tableData objectForKey:sectionTitle] count];
}

//
// Data Source methods
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GRKABPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitePageABPersonCell" forIndexPath:indexPath];
    [cell setupCellWithPerson: [self personAtIndexPath:indexPath]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GRKABPerson *person = [self personAtIndexPath:indexPath];
    person.selected = !person.selected;
    if (person.selected) {
        [self.selectedPhoneNumbers addObject:person.phoneNumbers[0]];
    } else {
        [self.selectedPhoneNumbers removeObject:person.phoneNumbers[0]];
    }
    [self.parentViewController ABTableViewControllerUpdatedNumberSelected:[self.selectedPhoneNumbers count]];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return tableSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

// Helpers
- (GRKABPerson *)personAtIndexPath:(NSIndexPath *)indexPath {
    // TODO unit test
    NSString *sectionTitle = [tableSections objectAtIndex:indexPath.section];
    return [[tableData objectForKey:sectionTitle] objectAtIndex:indexPath.row];
}

@end
