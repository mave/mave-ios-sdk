//
//  MAVEABTableViewController.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// This view controller can alert an additional delegate when the number of people selected changes
@protocol MAVEABTableViewAdditionalDelegate <NSObject>
@required
- (void)ABTableViewControllerNumberSelectedChanged:(unsigned long)num;
@end

@interface MAVEABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <MAVEABTableViewAdditionalDelegate> parentViewController;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *aboveTableContentView;
@property (strong, nonatomic) NSMutableSet *selectedPhoneNumbers;
@property (nonatomic) CGFloat lastScrolledShiftedOffsetY;

- (instancetype)initTableViewWithParent:(id<MAVEABTableViewAdditionalDelegate>)parent;

- (void)updateTableData:(NSDictionary *)data;

@end