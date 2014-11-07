//
//  MAVEDisplayOptions.h
//  MaveDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAVEDisplayOptions : NSObject

@property (strong, nonatomic) UIColor *navigationBarBackgroundColor;
@property (strong, nonatomic) UIColor *bottomViewBackgroundColor;
@property (strong, nonatomic) UIColor *tableCellBackgroundColor;
@property (strong, nonatomic) UIColor *tableSectionBackgroundColor;

- (MAVEDisplayOptions *)initWithDefaults;


@end
