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
    UIColor *lightGrey = [[UIColor alloc] initWithWhite:0.1 alpha:1];
    // UIColor *medGrey = [[UIColor alloc] initWithWhite:0.25 alpha:1];
    UIColor *white = [[UIColor alloc] initWithWhite:0 alpha:1];

    self.navigationBarBackgroundColor = white;
    self.bottomViewBackgroundColor = lightGrey;
    self.tableCellBackgroundColor = white;
    return self;
}


@end
