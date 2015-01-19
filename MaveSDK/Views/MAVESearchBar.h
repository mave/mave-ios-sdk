//
//  MAVESearchBar.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/16/15.
//
//

#import <UIKit/UIKit.h>

extern CGFloat const MAVESearchBarHeight;

@interface MAVESearchBar : UITextField

// the properties to be styled
@property (nonatomic, strong) UIFont *searchBarFont;
@property (nonatomic, strong) UIColor *searchBarPlaceholderTextColor;
@property (nonatomic, strong) UIColor *searchBarTextColor;
// and backgroundColor
@property (nonatomic, copy) NSString *placeholderText;
@property (nonatomic, copy) NSString *placeholderToFieldText;

- (instancetype)initWithSingletonSearchBarDisplayOptions;

@end