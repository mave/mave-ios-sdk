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
- (instancetype)initWithLabelText:(NSString *)labelText
                 sectionIsWaiting:(BOOL)sectionIsWaiting;

- (void)stopWaiting;

@end
