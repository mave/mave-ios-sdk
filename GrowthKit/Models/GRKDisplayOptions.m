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
        self.primaryFont = [UIFont systemFontOfSize:14];
        self.primaryTextColor = [[self class] colorAlmostBlack];
        self.secondaryTextColor = [[self class]colorLightGrey];
        self.tintColor = [[self class] colorBlueTint];

        self.navigationBarBackgroundColor = [[self class] colorWhite];
        self.bottomViewBackgroundColor = [[self class] colorWhite];
        self.tableCellBackgroundColor = [[self class] colorWhite];
        self.tableSectionBackgroundColor = [[self class] colorLightGrey];
    }
    return self;
}

+ (UIColor *)colorAlmostBlack { return [[UIColor alloc] initWithWhite:0.9 alpha:1.0]; }
+ (UIColor *)colorLightGrey { return [[UIColor alloc] initWithWhite:0.1 alpha:1.0]; }
+ (UIColor *)colorWhite { return [[UIColor alloc] initWithWhite:0.0 alpha:1.0]; }
+ (UIColor *)colorBlueTint {
    return [[UIColor alloc] initWithRed:0.0
                                  green:122.0/255.0
                                   blue:1.0
                                  alpha:1.0];
}

@end
