//
//  MAVEABTableViewController.m
//  MaveDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MAVEABTableViewController.h"
#import "MAVEABCollection.h"
#import "MAVEABPersonCell.h"
#import "MAVEABPerson.h"

@interface MAVEABTableViewController ()

@end

@implementation MAVEABTableViewController {
    NSDictionary *tableData;
    NSArray *tableSections;
}

- (MAVEABTableViewController *)initAndCreateTableViewWithFrame:(CGRect)frame {
    self = [super init];
    self.tableView = [[UITableView alloc] initWithFrame:frame];
    //    invitePageTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MAVEABPersonCell class] forCellReuseIdentifier:@"InvitePageABPersonCell"];
    
    self.selectedPhoneNumbers = [[NSMutableSet alloc] init];

    [MAVEABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
         [self updateTableData:indexedData];
     }];
    return self;
}

- (void) updateTableData:(NSDictionary *)data {
    tableData = data;
    tableSections = [[tableData allKeys]
                       sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (tableData == nil) {
        NSLog(@"It was nil!");
    }
    [self.tableView reloadData];
}

//
// Data Source methods
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [tableSections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = [tableSections objectAtIndex:section];
    return [[tableData objectForKey:sectionTitle] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitePageABPersonCell" forIndexPath:indexPath];
    [cell setupCellWithPerson: [self personAtIndexPath:indexPath]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: make more robust (if phone number is none)
    MAVEABPerson *person = [self personAtIndexPath:indexPath];
    person.selected = !person.selected;
    if (person.selected) {
        [self.selectedPhoneNumbers addObject:person.phoneNumbers[0]];
    } else {
        [self.selectedPhoneNumbers removeObject:person.phoneNumbers[0]];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

// Helpers
- (MAVEABPerson *)personAtIndexPath:(NSIndexPath *)indexPath {
    // TODO unit test
    NSString *sectionTitle = [tableSections objectAtIndex:indexPath.section];
    return [[tableData objectForKey:sectionTitle] objectAtIndex:indexPath.row];
}

@end
