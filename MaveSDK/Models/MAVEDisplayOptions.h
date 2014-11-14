//
//  MAVEDisplayOptions.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAVEDisplayOptions : NSObject

+ (UIColor *)colorAlmostBlack;
+ (UIColor *)colorMediumGrey;
+ (UIColor *)colorLightGrey;
+ (UIColor *)colorExtraLightGrey;
+ (UIColor *)colorWhite;
+ (UIColor *)colorBlueTint;

// Invite friends page options:
// Header options
@property (strong, nonatomic) NSString *navigationBarTitleCopy;
@property (strong, nonatomic) UIFont *navigationBarTitleFont;
@property (strong, nonatomic) UIColor *navigationBarTitleTextColor;
@property (strong, nonatomic) UIColor *navigationBarBackgroundColor;
// Note: any target & action set on the navigation bar cancel button item will
// be ignored, on cancel we run our own teardown code and then call your
// dismissalBlock
@property (strong, nonatomic) UIBarButtonItem *navigationBarCancelButton;

// "Friends to invite" table options
@property (strong, nonatomic) UIFont *contactNameFont;
@property (strong, nonatomic) UIColor *contactNameTextColor;
@property (strong, nonatomic) UIFont *contactDetailsFont;
@property (strong, nonatomic) UIColor *contactDetailsTextColor;
@property (strong, nonatomic) UIColor *contactCellBackgroundColor;
@property (strong, nonatomic) UIColor *contactCheckmarkColor;


@property (strong, nonatomic) UIFont *sectionHeaderFont;
@property (strong, nonatomic) UIColor *sectionHeaderColor;
@property (strong, nonatomic) UIColor *sectionHeaderBackgroundColor;
@property (strong, nonatomic) UIColor *sectionIndexColor;
@property (strong, nonatomic) UIColor *sectionIndexBackgroundColor;

// Message and Send section options
@property (strong, nonatomic) UIColor *bottomViewBackgroundColor;
@property (strong, nonatomic) UIColor *bottomViewBorderColor;
@property (strong, nonatomic) UIFont *sendButtonFont;
@property (strong, nonatomic) UIColor *sendButtonColor;

- (MAVEDisplayOptions *)initWithDefaults;

@end