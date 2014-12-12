//
//  MAVENoAddressBookPermissionView.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/11/14.
//
//

#import "MaveSDK.h"
#import "MAVENoAddressBookPermissionView.h"

@implementation MAVENoAddressBookPermissionView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"Contacts permission required";
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:self.titleLabel];
        
        // starting in iOS 8 we can link directly to current app settings page
        // This if statemenct checks if our constant is available
//        if (&UIApplicationOpenSettingsURLString != NULL) {
//            self.detailButton = [[UIButton alloc] init];
//            self.detailButton.titleLabel.text = @"Tap to go to Settings to enable";
//            [self.detailButton addTarget:self
//                                  action:@selector(openCurrentAppInSettings)
//                        forControlEvents:UIControlEventTouchUpInside];
//            [self addSubview:self.detailButton];
//        } else {
            self.detailLabel = [[UILabel alloc] init];
            self.detailLabel.text = @"Settings -> Privacy Settings -> Contacts\nto enable";
            self.detailLabel.numberOfLines = 0;
            self.detailLabel.font = [UIFont systemFontOfSize:13];
            self.detailLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.detailLabel];
//        }
    }
    return self;
}

- (void)openCurrentAppInSettings {
    // Works in iOS8 only, lower platforms shouldn't even call this method
    // but check again for the string just to be safe and not crash in iOS7
//    if (&UIApplicationOpenSettingsURLString == NULL) {
//        return;
//    }
//    [[UIApplication sharedApplication]
//        openURL: [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)layoutSubviews {
    // Layout Title label
    CGSize titleLabelSize = [self.titleLabel.text
        sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    float titleLabelX = (self.frame.size.width - titleLabelSize.width) / 2;
    float titleLabelY = 120;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelSize.width, titleLabelSize.height);
    
    if (self.detailLabel) {
        CGSize detailLabelSize = [self.detailLabel.text
            sizeWithAttributes:@{NSFontAttributeName: self.detailLabel.font}];
        float detailLabelX = (self.frame.size.width - detailLabelSize.width) / 2;
        float detailLabelY = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10;
        self.detailLabel.frame = CGRectMake(detailLabelX,
                                            detailLabelY,
                                            detailLabelSize.width,
                                            detailLabelSize.height);
    }
    if (self.detailButton) {
        self.detailButton.frame = CGRectMake(100, 100, 200, 200);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
