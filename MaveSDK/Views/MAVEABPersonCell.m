//
//  InvitePageABPersonCell.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MaveSDK.h"
#import "MAVEABPersonCell.h"
#import "MAVEDisplayOptions.h"

@implementation MAVEABPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:reuseIdentifier]) {
        MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        // Sets color of the default accessory checkmark
        [self setTintColor:displayOpts.contactCheckmarkColor];

        self.backgroundColor = displayOpts.contactCellBackgroundColor;
        self.textLabel.font = displayOpts.contactNameFont;
        self.textLabel.textColor = displayOpts.contactNameTextColor;
        self.detailTextLabel.font = displayOpts.contactDetailsFont;
        self.detailTextLabel.textColor = displayOpts.contactDetailsTextColor;
    }
    return self;
}

- (void)setupCellForNoPersonFound {
    self.textLabel.text = @"No results match";
    self.accessoryType = UITableViewCellAccessoryNone;
    self.detailTextLabel.text = nil;
    self.userInteractionEnabled = NO;
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
    self.userInteractionEnabled = YES;
}

@end
