//
//  InvitePageABPersonCell.h
//  MaveDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"

@interface MAVEABPersonCell : UITableViewCell

- (void)setupCellWithPerson:(MAVEABPerson *)person;

@end