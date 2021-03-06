//
//  MAVEDisplayOptionsFactory.m
//  MaveSDK
//
//  Created by dannycosson on 10/19/14.
//
//

#import <stdlib.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEDisplayOptions.h"

@implementation MAVEDisplayOptionsFactory

+ (MAVEDisplayOptions *)generateDisplayOptions {
    MAVEDisplayOptions *opts = [[MAVEDisplayOptions alloc] init];

    opts.navigationBarTitleCopy = @"Blah Copy";
    opts.navigationBarTitleFont = [self randomFont];
    opts.navigationBarTitleTextColor = [self randomColor];
    opts.navigationBarBackgroundColor = [self randomColor];
    opts.navigationBarCancelButton = [[UIBarButtonItem alloc] init];
    opts.navigationBarCancelButton.title = @"Cancel";

    opts.inviteExplanationCopy = @"Foo blah blah";
    opts.inviteExplanationFont = [self randomFont];
    opts.inviteExplanationTextColor = [self randomColor];
    opts.inviteExplanationCellBackgroundColor = [self randomColor];

    opts.inviteExplanationShareButtonsColor = [self randomColor];
    opts.inviteExplanationShareButtonsFont = [self randomFont];
    opts.inviteExplanationShareButtonsBackgroundColor = [self randomColor];

    opts.topViewMessageFont = [self randomFont];
    opts.topViewMessageTextColor = [self randomColor];
    opts.topViewMessageLabelFont = [self randomFont];
    opts.topViewMessageLabelTextColor = [self randomColor];
    opts.topViewBackgroundColor = [self randomColor];

    opts.searchBarFont = [self randomFont];
    opts.searchBarPlaceholderTextColor = [self randomColor];
    opts.searchBarSearchTextColor = [self randomColor];
    opts.searchBarBackgroundColor = [self randomColor];
    opts.searchBarTopBorderColor = [self randomColor];

    opts.contactNameFont = [self randomFont];
    opts.contactNameTextColor = [self randomColor];
    opts.contactDetailsFont = [self randomFont];
    opts.contactDetailsTextColor = [self randomColor];
    opts.contactSeparatorColor = [self randomColor];
    opts.contactCellBackgroundColor = [self randomColor];
    opts.contactCheckmarkColor = [self randomColor];
    opts.contactInlineSendButtonFont = [self randomFont];
    opts.contactInlineSendButtonTextColor = [self randomColor];
    opts.contactInlineSendButtonDisabledTextColor = [self randomColor];

    opts.contactSectionHeaderFont = [self randomFont];
    opts.contactSectionHeaderTextColor = [self randomColor];
    opts.contactSectionHeaderBackgroundColor = [self randomColor];
    opts.contactSectionIndexColor = [self randomColor];
    opts.contactSectionIndexBackgroundColor = [self randomColor];

    opts.messageFieldFont = [self randomFont];
    opts.messageFieldTextColor = [self randomColor];
    opts.messageFieldBackgroundColor = [self randomColor];
    opts.sendButtonCopy = @"Different Send";
    opts.sendButtonFont = [self randomFont];
    opts.sendButtonTextColor = [self randomColor];
    opts.bottomViewBackgroundColor = [self randomColor];
    opts.bottomViewBorderColor = [self randomColor];

    opts.invitePageV3TintColor = [self randomColor];

    opts.sharePageBackgroundColor = [self randomColor];
    opts.sharePageIconColor = [self randomColor];
    opts.sharePageIconFont = [self randomFont];
    opts.sharePageIconTextColor = [self randomColor];
    opts.sharePageExplanationFont = [self randomFont];
    opts.sharePageExplanationTextColor = [self randomColor];
    return opts;
}

+ (UIColor *)randomColor {
    CGFloat red = ((float)arc4random_uniform(256) / 256.0);
    CGFloat green = ((float)arc4random_uniform(256) / 256.0);
    CGFloat blue = ((float)arc4random_uniform(256) / 256.0);
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];
}
+ (UIFont *)randomFont {
    return [UIFont fontWithName:[self randomFontName] size:[self randomFontSize]];
}

// Return a random int in a normal-ish range of font sizes
+ (NSInteger)randomFontSize {
    // uniform random int 12-24
    return arc4random_uniform(12) + 12;
}

// Return a random value from a hard-coded list of builtin ios7+ fonts
+ (NSString *)randomFontName {
    NSString *fontName;
    switch(arc4random_uniform(8)) {
        case 0:
            fontName = @"AppleSDGothicNeo-Thin"; break;
        case 1:
            fontName = @"AmericanTypewriter"; break;
        case 2:
            fontName = @"ArialMT"; break;
        case 3:
            fontName = @"Avenir-Light"; break;
        case 4:
            fontName = @"AvenirNext-UltraLight"; break;
        case 5:
            fontName = @"Chalkduster"; break;
        case 6:
            fontName = @"Copperplate"; break;
        case 7:
            fontName = @"CourierNewPSMT"; break;
    }
    return fontName;
}

@end
