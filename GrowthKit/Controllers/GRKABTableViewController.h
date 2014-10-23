//
//  GRKABTableViewController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// This view controller can alert an additional delegate when the number of people selected changes
@protocol GRKABTableViewAdditionalDelegate <NSObject>
@required
- (void)ABTableViewControllerNumberSelectedChanged:(unsigned long)num;
@end

@interface GRKABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <GRKABTableViewAdditionalDelegate> parentViewController;
@property UITableView *tableView;
@property (strong, nonatomic) NSMutableSet *selectedPhoneNumbers;

- (instancetype)initTableViewWithFrame:(CGRect)frame
                                parent:(id<GRKABTableViewAdditionalDelegate>)parent;
- (void)updateTableData:(NSDictionary *)data;

@end