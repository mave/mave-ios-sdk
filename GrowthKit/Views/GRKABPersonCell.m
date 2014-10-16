//
//  InvitePageABPersonCell.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "GRKABPersonCell.h"

@implementation GRKABPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    return self;
}

- (void)setupCellWithPerson:(GRKABPerson *)person {
    self.textLabel.text = [person fullName];
    if (person.selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.detailTextLabel.text = [person bestPhone];
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.detailTextLabel.text = nil;
    }
}

@end
