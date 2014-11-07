//
//  InvitePageABPersonCell.m
//  MaveDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "Mave.h"
#import "MAVEABPersonCell.h"
#import "MAVEDisplayOptions.h"

@implementation MAVEABPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:reuseIdentifier]) {
        MAVEDisplayOptions *displayOpts = [Mave sharedInstance].displayOptions;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        // Sets color of the default accessory checkmark
        [self setTintColor:displayOpts.checkmarkColor];

        self.textLabel.font = displayOpts.personNameFont;
        self.textLabel.textColor = [MAVEDisplayOptions colorAlmostBlack];
        self.detailTextLabel.font = displayOpts.personContactInfoFont;
        self.detailTextLabel.textColor = [MAVEDisplayOptions colorMediumGrey];
    }
    return self;
}

- (void)setupCellWithPerson:(MAVEABPerson *)person {
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
