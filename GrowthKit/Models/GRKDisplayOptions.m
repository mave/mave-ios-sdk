//
//  GRKDisplayOptions.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRKDisplayOptions.h"


@implementation GRKDisplayOptions

- (GRKDisplayOptions *)initWithDefaults {
    if (self = [super init]) {
        // Header options
        self.navigationBarBackgroundColor = [[self class] colorWhite];
        self.navigationBarTitleColor = [[self class] colorAlmostBlack];
        self.navigationBarTitleFont = [UIFont systemFontOfSize:14];
        self.navigationBarCancelButton = [[UIBarButtonItem alloc] init];
        self.navigationBarCancelButton.title = @"Cancel";

        // "Friends to invite" table options
        self.personNameFont = [UIFont systemFontOfSize:14];
        self.personContactInfoFont = [UIFont systemFontOfSize:12];
        self.sectionHeaderFont = [UIFont boldSystemFontOfSize:12];
        self.sectionIndexColor = [[self class] colorLightGrey];
        self.checkmarkColor = [[self class] colorBlueTint];
        
        // Message and Send section options
        self.bottomViewBackgroundColor = [[self class] colorWhite];
        self.bottomViewBorderColor = [[self class] colorMediumGrey];
        self.sendButtonFont = [UIFont systemFontOfSize:14];
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
