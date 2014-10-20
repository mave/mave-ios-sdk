//
//  GRKDisplayOptionsFactory.m
//  GrowthKit
//
//  Created by dannycosson on 10/19/14.
//
//

#import <stdlib.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GRKDisplayOptionsFactory.h"
#import "GRKDisplayOptions.h"

@implementation GRKDisplayOptionsFactory

+ (GRKDisplayOptions *)generateDisplayOptions {
    GRKDisplayOptions *opts = [[GRKDisplayOptions alloc] init];

    opts.primaryFont = [self randomFont];
    opts.primaryTextColor = [self randomColor];
    opts.secondaryTextColor = [self randomColor];
    opts.tintColor = [self randomColor];

    opts.navigationBarBackgroundColor = [self randomColor];
    opts.bottomViewBackgroundColor  = [self randomColor];
    opts.tableCellBackgroundColor = [self randomColor];
    opts.tableSectionHeaderBackgroundColor = [self randomColor];

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