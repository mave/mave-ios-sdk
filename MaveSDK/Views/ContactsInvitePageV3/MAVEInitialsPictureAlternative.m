//
//  MAVEInitialsPictureAlternative.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/29/15.
//
//

#import "MAVEInitialsPictureAlternative.h"
#import "MAVEDisplayOptions.h"

@implementation MAVEInitialsPictureAlternative {
    BOOL _didSetupInitialConstraints;
}

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    self.backgroundColor = [MAVEDisplayOptions colorAppleMediumGray];
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    self.label.font = font;
    [self addSubview:self.label];
}

- (void)setupInitialConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

@end
