//
//  MAVEContactIdentifierWithLabelBase.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import "MAVEContactIdentifierWithLabelBase.h"

@implementation MAVEContactIdentifierWithLabelBase

- (instancetype)initWithValue:(NSString *)value andLabel:(NSString *)label {
    if (self = [super init]) {
        self.typeName = [[self class] ownTypeName];
        self.value = value;
        self.label = label;
    }
    return self;
}

- (NSString *)humanReadableLabel {
    return self.label;
}

- (NSString *)humanReadableValueWithLabel {
    return [NSString stringWithFormat:@"%@ (%@)", [self humanReadableValue], [self humanReadableLabel]];
}

@end
