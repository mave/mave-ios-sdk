//
//  InvitePageABPersonCell.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GRKABPerson.h"

@interface GRKABPersonCell : UITableViewCell

- (void)setupCellWithPerson:(GRKABPerson *)person;

@end