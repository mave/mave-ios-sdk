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

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.animationImages = @[
        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots1" fromBundle:MAVEResourceBundleName],
//        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots2" fromBundle:MAVEResourceBundleName],
//        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots3" fromBundle:MAVEResourceBundleName],
        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots4" fromBundle:MAVEResourceBundleName],
//        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots5" fromBundle:MAVEResourceBundleName],
//        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots6" fromBundle:MAVEResourceBundleName],
        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots7" fromBundle:MAVEResourceBundleName],
//        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots8" fromBundle:MAVEResourceBundleName],
//        [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots9" fromBundle:MAVEResourceBundleName],
    ];
    self.animationDuration = 0.8;
    self.animationRepeatCount = 0;
    [self startAnimating ];
}

@end
