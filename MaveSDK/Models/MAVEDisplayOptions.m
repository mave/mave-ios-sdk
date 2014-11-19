//
//  MAVEDisplayOptions.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEDisplayOptions.h"


@implementation MAVEDisplayOptions

- (MAVEDisplayOptions *)initWithDefaults {
    if (self = [super init]) {
        // Header options
        self.navigationBarTitleCopy = @"Invite Friends";
        self.navigationBarTitleFont = [UIFont systemFontOfSize:16];
        self.navigationBarTitleTextColor = [[self class] colorAlmostBlack];
        self.navigationBarBackgroundColor = [[self class] colorWhite];
        self.navigationBarCancelButton = [[UIBarButtonItem alloc] init];
        self.navigationBarCancelButton.title = @"Cancel";
        
        // Explanation of how the referral program works section
        self.userExplanationCopy = nil;
        self.userExplanationFont = [UIFont systemFontOfSize:14];
        self.userExplanationTextColor = [[self class] colorAlmostBlack];
        self.userExplanationCellBackgroundColor = [[self class] colorExtraLightGrey];

        // "Friends to invite" table options
        self.contactNameFont = [UIFont systemFontOfSize:16];
        self.contactNameTextColor = [[self class] colorAlmostBlack];
        self.contactDetailsFont = [UIFont systemFontOfSize:14];
        self.contactDetailsTextColor = [[self class] colorMediumGrey];
        self.contactSeparatorColor = [[self class] colorExtraLightGrey];
        self.contactCellBackgroundColor = [[self class] colorWhite];
        self.contactCheckmarkColor = [[self class] colorBlueTint];

        self.contactSectionHeaderFont = [UIFont boldSystemFontOfSize:14];
        self.contactSectionHeaderTextColor = [[self class] colorAlmostBlack];
        self.contactSectionHeaderBackgroundColor = [[self class] colorExtraLightGrey];
        self.contactSectionIndexColor = [[self class] colorLightGrey];
        self.contactSectionIndexBackgroundColor = [[self class] colorWhite];

        // Message and Send section options
        self.messageFieldFont = [UIFont systemFontOfSize:16];
        self.messageFieldTextColor = [[self class] colorAlmostBlack];
        self.messageFieldBackgroundColor = [[self class] colorWhite];
        self.sendButtonFont = [UIFont systemFontOfSize:18];
        self.sendButtonTextColor = [[self class] colorBlueTint];
        self.bottomViewBorderColor = [[self class] colorMediumGrey];
        self.bottomViewBackgroundColor = [[self class] colorWhite];
    }
    return self;
}

+ (UIColor *)colorAlmostBlack { return [[UIColor alloc] initWithWhite:0.15 alpha:1.0]; }
+ (UIColor *)colorMediumGrey { return [[UIColor alloc] initWithWhite:0.65 alpha:1.0]; }
+ (UIColor *)colorLightGrey { return [[UIColor alloc] initWithWhite:0.70 alpha:1.0]; }
+ (UIColor *)colorExtraLightGrey { return [[UIColor alloc] initWithWhite:0.95 alpha:1.0]; }
+ (UIColor *)colorWhite { return [[UIColor alloc] initWithWhite:1.0 alpha:1.0]; }
+ (UIColor *)colorBlueTint {
    return [[UIColor alloc] initWithRed:0.0
                                  green:122.0/255.0
                                   blue:1.0
                                  alpha:1.0];
}

@end
