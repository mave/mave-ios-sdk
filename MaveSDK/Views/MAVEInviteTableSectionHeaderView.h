//
//  MAVEInviteTableSectionHeaderView.h
//  MaveSDK
//
//  Created by Danny Cosson on 2/19/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEWaitingDotsImageView.h"

@interface MAVEInviteTableSectionHeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MAVEWaitingDotsImageView *waitingDotsView;

// Initializer for creating and laying out this view
// If SectionIsPending is true, we add the waiting dots (like in
// the messages app) next to the label
// Uses the displayOptions singleton for font, text color, bg color
- (instancetype)initWithLabelText:(NSString *)labelText
                 sectionIsWaiting:(BOOL)sectionIsWaiting;

// Longer initializer with explicitly set colors
- (instancetype)initWithLabelText:(NSString *)labelText
                 sectionIsWaiting:(BOOL)sectionIsWaiting
                        textColor:(UIColor *)textColor
                  backgroundColor:(UIColor *)backgroundColor
                             font:(UIFont *)font;

- (void)stopWaiting;

@end
