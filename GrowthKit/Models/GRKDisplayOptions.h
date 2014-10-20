//
//  GRKDisplayOptions.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GRKDisplayOptions : NSObject

@property (strong, nonatomic) UIFont *primaryFont;
@property (strong, nonatomic) UIColor *primaryTextColor;
@property (strong, nonatomic) UIColor *secondaryTextColor;
@property (strong, nonatomic) UIColor *tintColor;

@property (strong, nonatomic) UIColor *navigationBarBackgroundColor;
@property (strong, nonatomic) UIColor *bottomViewBackgroundColor;
@property (strong, nonatomic) UIColor *tableCellBackgroundColor;
@property (strong, nonatomic) UIColor *tableSectionBackgroundColor;

- (GRKDisplayOptions *)initWithDefaults;


@end
