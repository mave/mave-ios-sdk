//
//  MAVEWaitingDotsView.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/19/15.
//
//

#import "MAVEWaitingDotsImageView.h"
#import "MAVEConstants.h"
#import "MAVEBuiltinUIElementUtils.h"

@implementation MAVEWaitingDotsImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.animationImages = @[
        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots1" fromBundle:MAVEResourceBundleName],
        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots2" fromBundle:MAVEResourceBundleName],
        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots3" fromBundle:MAVEResourceBundleName],
    ];
    self.animationDuration = 0.7;
    self.animationRepeatCount = 0;
    [self startAnimating ];
}

@end
