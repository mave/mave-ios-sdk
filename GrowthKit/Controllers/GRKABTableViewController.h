//
//  GRKABTableViewController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRKInvitePageViewController;

@interface GRKABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) GRKInvitePageViewController *parentViewController;
@property UITableView *tableView;
@property (strong, nonatomic) NSMutableSet *selectedPhoneNumbers;

- (instancetype)initTableViewWithFrame:(CGRect)frame
                                parent:(GRKInvitePageViewController *)parent;
- (void)updateTableData:(NSDictionary *)data;

@end