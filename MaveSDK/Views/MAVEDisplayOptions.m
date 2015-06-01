//
//  MAVEDisplayOptions.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEDisplayOptions.h"


@implementation MAVEDisplayOptions

- (MAVEDisplayOptions *)initWithDefaults {
    if (self = [super init]) {
        // Header options
        self.statusBarStyle = UIStatusBarStyleDefault;
        self.navigationBarTitleCopy = @"Invite Friends";
        self.navigationBarTitleFont = [UIFont systemFontOfSize:16];
        self.navigationBarTitleTextColor = [[self class] colorAlmostBlack];
        self.navigationBarBackgroundColor = [[self class] colorWhite];

        // If pushing onto the navigation stack, you can set self.navigationBarBackButton
        // && self.navigationBarForwardButton

        // Above table content - invite page v1 specific
        //  - "invite explanation" text, an explanation of how the referral program works
        //  - optional share icons on the invite page
        // Explanation of how the referral program works section
        self.inviteExplanationFont = [UIFont systemFontOfSize:14];
        self.inviteExplanationTextColor = [[self class] colorAlmostBlack];
        self.inviteExplanationCellBackgroundColor = [[self class] colorExtraLightGrey];

        self.inviteExplanationShareButtonsColor = [[self class] colorMediumGrey];
        self.inviteExplanationShareButtonsFont = [UIFont systemFontOfSize:10];
        self.inviteExplanationShareButtonsBackgroundColor = [[self class] colorExtraLightGrey];

        // Above table content - invite page v2 specific
        //  - invite message (user-customizable text that will be sent in the invite)
        //    above the table view
        self.topViewMessageFont = [UIFont systemFontOfSize:14];
        self.topViewMessageTextColor = [[self class] colorAlmostBlack];
        self.topViewMessageLabelFont = [UIFont systemFontOfSize:14];
        self.topViewMessageLabelTextColor = [[self class] colorMediumGrey];
        self.topViewBackgroundColor = [[self class] colorWhite];

        // Search Bar
        self.searchBarFont = [UIFont systemFontOfSize:16];
        self.searchBarPlaceholderTextColor = [[self class] colorMediumGrey];
        self.searchBarSearchTextColor = [[self class] colorAlmostBlack];
        self.searchBarBackgroundColor = [[self class] colorWhite];
        self.searchBarTopBorderColor = [[self class] colorExtraLightGrey];

        // "Friends to invite" table options
        self.contactNameFont = [UIFont systemFontOfSize:16];
        self.contactNameTextColor = [[self class] colorAlmostBlack];
        self.contactDetailsFont = [UIFont systemFontOfSize:14];
        self.contactDetailsTextColor = [[self class] colorMediumGrey];
        self.contactSeparatorColor = [[self class] colorExtraLightGrey];
        self.contactCellBackgroundColor = [[self class] colorWhite];
        self.contactCheckmarkColor = [[self class] colorBlueTint];
        self.contactInlineSendButtonFont = [UIFont systemFontOfSize:16];
        self.contactInlineSendButtonTextColor = [[self class] colorBlueTint];
        self.contactInlineSendButtonDisabledTextColor = [[self class] colorMediumGrey];

        self.contactSectionHeaderFont = [UIFont boldSystemFontOfSize:14];
        self.contactSectionHeaderTextColor = [[self class] colorAlmostBlack];
        self.contactSectionHeaderBackgroundColor = [[self class] colorExtraLightGrey];
        self.contactSectionIndexColor = [[self class] colorLightGrey];
        self.contactSectionIndexBackgroundColor = [UIColor clearColor];

        // Message and Send section options, only used with invite page v1
        self.messageFieldFont = [UIFont systemFontOfSize:16];
        self.messageFieldTextColor = [[self class] colorAlmostBlack];
        self.messageFieldBackgroundColor = [[self class] colorWhite];
        self.sendButtonCopy = @"Send";
        self.sendButtonFont = [UIFont systemFontOfSize:18];
        self.sendButtonTextColor = [[self class] colorBlueTint];
        self.bottomViewBorderColor = [[self class] colorMediumGrey];
        self.bottomViewBackgroundColor = [[self class] colorWhite];

        // Invite page V3
        self.invitePageV3TintColor = [[self class]colorAppleBlueTint];

        // SharePage options
        //background
        self.sharePageBackgroundColor = [[self class] colorExtraLightGrey];
        self.sharePageIconColor = [[self class] colorBlueTint];
        self.sharePageIconFont = [UIFont systemFontOfSize:12];
        self.sharePageIconTextColor = [[self class] colorMediumGrey];
        self.sharePageExplanationFont = [UIFont systemFontOfSize:16];
        self.sharePageExplanationTextColor = [[self class] colorAlmostBlack];
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

+ (UIColor *)colorAppleBlueTint {
    return [UIColor colorWithRed:3.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
}
+ (UIColor *)colorAppleLightGray {
    return [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:230.0/255.0 alpha:1.0];
}
+ (UIColor *)colorAppleMediumGray {
    return [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1.0];
}
+ (UIColor *)colorAppleDarkGray {
    return [UIColor colorWithRed:144.0/255.0 green:144.0/255.0 blue:148.0/255.0 alpha:1.0];
}
+ (UIColor *)colorAppleBlack {
    return [UIColor blackColor];
}

+ (UIFont *)invitePageV3BiggerFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:17];
}
+ (UIFont *)invitePageV3BiggerLightFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *)invitePageV3SmallerFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:13];

}

@end
