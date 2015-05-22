//
//  MAVEBigSendButton.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEBigSendButton.h"

@implementation MAVEBigSendButton

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
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.tintColor = [UIColor whiteColor];
}

@end
