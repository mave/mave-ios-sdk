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
@property (strong, nonatomic) UIFont  *contactNameFont;
@property (strong, nonatomic) UIColor *contactNameTextColor;
@property (strong, nonatomic) UIFont  *contactDetailsFont;
@property (strong, nonatomic) UIColor *contactDetailsTextColor;
@property (strong, nonatomic) UIColor *contactSeparatorColor;
@property (strong, nonatomic) UIColor *contactCellBackgroundColor;
@property (strong, nonatomic) UIColor *contactCheckmarkColor;

@property (strong, nonatomic) UIFont  *contactSectionHeaderFont;
@property (strong, nonatomic) UIColor *contactSectionHeaderTextColor;
@property (strong, nonatomic) UIColor *contactSectionHeaderBackgroundColor;
@property (strong, nonatomic) UIColor *contactSectionIndexColor;
@property (strong, nonatomic) UIColor *contactSectionIndexBackgroundColor;

// Message and Send section options
@property (strong, nonatomic) UIFont  *messageFieldFont;
@property (strong, nonatomic) UIColor *messageFieldTextColor;
@property (strong, nonatomic) UIColor *messageFieldBackgroundColor;
@property (strong, nonatomic) UIFont  *sendButtonFont;
@property (strong, nonatomic) UIColor *sendButtonTextColor;
@property (strong, nonatomic) UIColor *bottomViewBackgroundColor;
@property (strong, nonatomic) UIColor *bottomViewBorderColor;

- (MAVEDisplayOptions *)initWithDefaults;

@end