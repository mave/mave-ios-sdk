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

@property (nonatomic, weak) id <MAVEABTableViewAdditionalDelegate> parentViewController;
@property UITableView *tableView;
@property (strong, nonatomic) NSMutableSet *selectedPhoneNumbers;

- (instancetype)initTableViewWithFrame:(CGRect)frame
                                parent:(id<MAVEABTableViewAdditionalDelegate>)parent;
- (void)updateTableData:(NSDictionary *)data;

@end