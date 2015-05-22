//
//  MAVECustomCheckboxV3.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import "MAVECustomCheckboxV3.h"

@implementation MAVECustomCheckboxV3

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

}

@end
