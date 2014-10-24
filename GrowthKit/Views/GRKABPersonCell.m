//
//  InvitePageABPersonCell.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "GrowthKit.h"
#import "GRKABPersonCell.h"
#import "GRKDisplayOptions.h"

@implementation GRKABPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:reuseIdentifier]) {
        GRKDisplayOptions *displayOpts = [GrowthKit sharedInstance].displayOptions;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        // Sets color of the default accessory checkmark
        [self setTintColor:displayOpts.secondaryTextColor];

        [self.textLabel setFont:displayOpts.primaryFont];
        self.textLabel.textColor = displayOpts.primaryTextColor;
        self.detailTextLabel.textColor = displayOpts.secondaryTextColor;
    }
    return self;
}

- (void)setupCellWithPerson:(GRKABPerson *)person {
    self.textLabel.text = [person fullName];
    if (person.selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.detailTextLabel.text = [[person class] displayPhoneNumber:[person bestPhone]];
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.detailTextLabel.text = nil;
    }
}

@end
