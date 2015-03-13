//
//  InvitePageABPersonCell.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"

#define MAVEInvitePageABPersonCellID @"MAVEInvitePageABPersonCell"

@interface MAVEABPersonCell : UITableViewCell

- (void)setupCellForNoPersonFound;
- (void)setupCellWithPerson:(MAVEABPerson *)person;

@end
