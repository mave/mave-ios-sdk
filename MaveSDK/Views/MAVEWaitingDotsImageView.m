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
    UIImage *image1 = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots1" fromBundle:MAVEResourceBundleName];
    UIImage *image2 = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots2" fromBundle:MAVEResourceBundleName];
    UIImage *image3 = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEWaitingDots3" fromBundle:MAVEResourceBundleName];
    if (!(image1 && image2 && image3)) {
        MAVEErrorLog(@"Could not load the \"waiting dots\" image, image will be blank");
        return;
    }

    self.animationImages = @[image1, image2, image3];
    self.animationDuration = 0.7;
    self.animationRepeatCount = 0;
    [self startAnimating ];
}

@end
