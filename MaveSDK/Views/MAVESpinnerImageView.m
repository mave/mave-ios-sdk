//
//  MAVESpinnerImageView.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/13/15.
//
//

#import "MAVESpinnerImageView.h"
#import "MAVEBuiltinUIElementUtils.h"

@implementation MAVESpinnerImageView

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    NSString *bundleName = @"MaveSDK";
    self.animationImages = [NSArray arrayWithObjects:
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt1" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt2" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt3" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt4" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt5" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt6" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt7" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt8" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt9" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt10" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt11" fromBundle:bundleName],
                            [MAVEBuiltinUIElementUtils imageNamed:@"MAVESpinnerPt12" fromBundle:bundleName],
                            nil];
    self.animationDuration = 0.7f;
    self.animationRepeatCount = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self startAnimating];
}

@end
