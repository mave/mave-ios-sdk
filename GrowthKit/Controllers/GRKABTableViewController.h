//
//  GRKABTableViewController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRKABTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property UITableView *tableView;
@property (strong, nonatomic) NSMutableSet *selectedPhoneNumbers;

- (instancetype)initWithFrame:(CGRect)frame andData:(NSDictionary *)indexedABData;

- (void)updateTableData:(NSDictionary *)data;

@end
