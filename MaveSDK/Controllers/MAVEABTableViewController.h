//
//  MAVEABTableViewController.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEInviteTableHeaderView.h"

// This view controller can alert an additional delegate when the number of people selected changes
@protocol MAVEABTableViewAdditionalDelegate <NSObject>
@required
- (void)ABTableViewControllerNumberSelectedChanged:(unsigned long)num;
@end

@interface MAVEABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) UIViewController<MAVEABTableViewAdditionalDelegate> *parentViewController;
@property (nonatomic, strong) MAVEInviteTableHeaderView *inviteTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *aboveTableContentView;
@property (nonatomic, strong) NSMutableSet *selectedPhoneNumbers;

@property (nonatomic, strong) NSArray *allPersons; // for search

- (instancetype)initTableViewWithParent:(UIViewController<MAVEABTableViewAdditionalDelegate> *)parent;

- (void)updateTableData:(NSDictionary *)data;

- (void)layoutHeaderViewForWidth:(CGFloat)width;

@end