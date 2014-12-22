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

@interface MAVEABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <MAVEABTableViewAdditionalDelegate> parentViewController;
@property (nonatomic, strong) MAVEInviteTableHeaderView *inviteTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *aboveTableContentView;
@property (nonatomic, strong) NSMutableSet *selectedPhoneNumbers;

- (instancetype)initTableViewWithParent:(id<MAVEABTableViewAdditionalDelegate>)parent;

- (void)updateTableData:(NSDictionary *)data;

- (void)layoutHeaderViewForWidth:(CGFloat)width;

@end