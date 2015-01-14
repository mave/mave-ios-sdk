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

// Contacts list invite friends page options:
// Header options (also used by share page invite page)
@property (nonatomic, copy) NSString *navigationBarTitleCopy;
@property (nonatomic, strong) UIFont   *navigationBarTitleFont;
@property (nonatomic, strong) UIColor  *navigationBarTitleTextColor;
@property (nonatomic, strong) UIColor  *navigationBarBackgroundColor;
// Note: any target & action set on the navigation bar cancel button item will
// be ignored, on cancel we run our own teardown code and then call your
// dismissalBlock
@property (nonatomic, strong) UIBarButtonItem *navigationBarCancelButton;

// Explanation of how the referral program works section
@property (nonatomic, copy) NSString *inviteExplanationCopy;
@property (nonatomic, strong) UIFont   *inviteExplanationFont;
@property (nonatomic, strong) UIColor  *inviteExplanationTextColor;
@property (nonatomic, strong) UIColor  *inviteExplanationCellBackgroundColor;

// "Friends to invite" table options
@property (nonatomic, strong) UIFont  *contactNameFont;
@property (nonatomic, strong) UIColor *contactNameTextColor;
@property (nonatomic, strong) UIFont  *contactDetailsFont;
@property (nonatomic, strong) UIColor *contactDetailsTextColor;
@property (nonatomic, strong) UIColor *contactSeparatorColor;
@property (nonatomic, strong) UIColor *contactCellBackgroundColor;
@property (nonatomic, strong) UIColor *contactCheckmarkColor;

@property (nonatomic, strong) UIFont  *contactSectionHeaderFont;
@property (nonatomic, strong) UIColor *contactSectionHeaderTextColor;
@property (nonatomic, strong) UIColor *contactSectionHeaderBackgroundColor;
@property (nonatomic, strong) UIColor *contactSectionIndexColor;
@property (nonatomic, strong) UIColor *contactSectionIndexBackgroundColor;

// Message and Send section options
@property (nonatomic, strong) UIFont  *messageFieldFont;
@property (nonatomic, strong) UIColor *messageFieldTextColor;
@property (nonatomic, strong) UIColor *messageFieldBackgroundColor;
@property (nonatomic, copy) NSString *sendButtonCopy;
@property (nonatomic, strong) UIFont  *sendButtonFont;
@property (nonatomic, strong) UIColor *sendButtonTextColor;
@property (nonatomic, strong) UIColor *bottomViewBackgroundColor;
@property (nonatomic, strong) UIColor *bottomViewBorderColor;

///
/// Share page invite page
///
@property (nonatomic, strong) UIColor *sharePageBackgroundColor;

// Icons
@property (nonatomic, strong) UIColor *sharePageIconColor;
@property (nonatomic, strong) UIFont *sharePageIconFont;
@property (nonatomic, strong) UIColor *sharePageIconTextColor;

// Explanation copy
@property (nonatomic, strong) UIFont *sharePageExplanationFont;
@property (nonatomic, strong) UIColor *sharePageExplanationTextColor;


- (MAVEDisplayOptions *)initWithDefaults;

@end