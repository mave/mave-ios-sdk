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

        // "Friends to invite" table options
        self.contactNameFont = [UIFont systemFontOfSize:16];
        self.contactNameTextColor = [[self class] colorAlmostBlack];
        self.contactDetailsFont = [UIFont systemFontOfSize:14];
        self.contactDetailsTextColor = [[self class] colorMediumGrey];
        self.contactCellBackgroundColor = [[self class] colorWhite];
        self.contactCheckmarkColor = [[self class] colorBlueTint];

        self.sectionHeaderFont = [UIFont boldSystemFontOfSize:14];
        self.sectionHeaderColor = [[self class] colorAlmostBlack];
        self.sectionHeaderBackgroundColor = [[self class] colorExtraLightGrey];
        self.sectionIndexColor = [[self class] colorLightGrey];
        self.sectionIndexBackgroundColor = [[self class] colorWhite];

        // Message and Send section options
        self.bottomViewBackgroundColor = [[self class] colorWhite];
        self.bottomViewBorderColor = [[self class] colorMediumGrey];
        self.sendButtonFont = [UIFont systemFontOfSize:18];
        self.sendButtonColor = [[self class] colorBlueTint];
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
