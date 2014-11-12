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
        [self setTintColor:displayOpts.checkmarkColor];

        self.backgroundColor = displayOpts.personCellBackgroundColor;
        self.textLabel.font = displayOpts.personNameFont;
        self.textLabel.textColor = displayOpts.personNameColor;
        self.detailTextLabel.font = displayOpts.personContactInfoFont;
        self.detailTextLabel.textColor = displayOpts.personContactInfoColor;
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
