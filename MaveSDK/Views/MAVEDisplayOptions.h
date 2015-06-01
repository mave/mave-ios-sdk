//
//  MAVEDisplayOptions.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/9/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
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

+ (UIColor *)colorAppleBlueTint;
+ (UIColor *)colorAppleLightGray;
+ (UIColor *)colorAppleMediumGray;
+ (UIColor *)colorAppleDarkGray;
+ (UIColor *)colorAppleBlack;

// Shared options
// Contacts list invite friends page options:
// Header options (also used by share page invite page)
@property (nonatomic, copy) NSString *navigationBarTitleCopy;
@property (nonatomic, strong) UIFont   *navigationBarTitleFont;
@property (nonatomic, strong) UIColor  *navigationBarTitleTextColor;
@property (nonatomic, strong) UIColor  *navigationBarBackgroundColor;

// Note: any target & action set on the navigation bar buttons will
// be ignored, we run the block you provide instead.
//
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
// Cancel button is used when the invite page is presented modally
// (whether native present modally or some custom way like in a drawer, etc).
@property (nonatomic, strong) UIBarButtonItem *navigationBarCancelButton;
// Back and forward buttons are used when the invite page is pushed
@property (nonatomic, strong) UIBarButtonItem *navigationBarBackButton;
@property (nonatomic, strong) UIBarButtonItem *navigationBarForwardButton;

// Above table content - invite page v1 specific
//  - "invite explanation" text, an explanation of how the referral program works
//  - optional share icons on the invite page
@property (nonatomic, copy) NSString  *inviteExplanationCopy;
@property (nonatomic, strong) UIFont  *inviteExplanationFont;
@property (nonatomic, strong) UIColor *inviteExplanationTextColor;
@property (nonatomic, strong) UIColor *inviteExplanationCellBackgroundColor;

@property (nonatomic, strong) UIColor *inviteExplanationShareButtonsColor;
@property (nonatomic, strong) UIFont  *inviteExplanationShareButtonsFont;
@property (nonatomic, strong) UIColor *inviteExplanationShareButtonsBackgroundColor;

// Above table content - invite page v2 specific
//  - invite message (user-customizable text that will be sent in the invite)
//    above the table view
@property (nonatomic, strong) UIFont  *topViewMessageLabelFont;
@property (nonatomic, strong) UIColor *topViewMessageLabelTextColor;
@property (nonatomic, strong) UIFont  *topViewMessageFont;
@property (nonatomic, strong) UIColor *topViewMessageTextColor;
@property (nonatomic, strong) UIColor *topViewBackgroundColor;

// Search bar options
@property (nonatomic, strong) UIFont *searchBarFont;
@property (nonatomic, strong) UIColor *searchBarPlaceholderTextColor;
@property (nonatomic, strong) UIColor *searchBarSearchTextColor;
@property (nonatomic, strong) UIColor *searchBarBackgroundColor;
@property (nonatomic, strong) UIColor *searchBarTopBorderColor;

// "Friends to invite" table options
@property (nonatomic, strong) UIFont  *contactNameFont;
@property (nonatomic, strong) UIColor *contactNameTextColor;
@property (nonatomic, strong) UIFont  *contactDetailsFont;
@property (nonatomic, strong) UIColor *contactDetailsTextColor;
@property (nonatomic, strong) UIColor *contactSeparatorColor;
@property (nonatomic, strong) UIColor *contactCellBackgroundColor;
@property (nonatomic, strong) UIColor *contactCheckmarkColor;
@property (nonatomic, strong) UIFont  *contactInlineSendButtonFont;
@property (nonatomic, strong) UIColor *contactInlineSendButtonTextColor;
@property (nonatomic, strong) UIColor *contactInlineSendButtonDisabledTextColor;

@property (nonatomic, strong) UIFont  *contactSectionHeaderFont;
@property (nonatomic, strong) UIColor *contactSectionHeaderTextColor;
@property (nonatomic, strong) UIColor *contactSectionHeaderBackgroundColor;
@property (nonatomic, strong) UIColor *contactSectionIndexColor;
@property (nonatomic, strong) UIColor *contactSectionIndexBackgroundColor;

// Message and Send section options (only used with invite page v1)
@property (nonatomic, strong) UIFont  *messageFieldFont;
@property (nonatomic, strong) UIColor *messageFieldTextColor;
@property (nonatomic, strong) UIColor *messageFieldBackgroundColor;
@property (nonatomic, copy) NSString  *sendButtonCopy;
@property (nonatomic, strong) UIFont  *sendButtonFont;
@property (nonatomic, strong) UIColor *sendButtonTextColor;
@property (nonatomic, strong) UIColor *bottomViewBackgroundColor;
@property (nonatomic, strong) UIColor *bottomViewBorderColor;

///
/// Invite page V3
///
@property (nonatomic, strong) UIColor *invitePageV3TintColor;
+ (UIFont *)invitePageV3BiggerFont;
+ (UIFont *)invitePageV3BiggerLightFont;
+ (UIFont *)invitePageV3SmallerFont;
+ (UIFont *)invitePageV3SmallerLightFont;

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
