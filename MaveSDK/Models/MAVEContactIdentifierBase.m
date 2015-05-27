//
//  MAVEContactIdentifierBase.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/26/15.
//
//

#import "MAVEContactIdentifierBase.h"

@implementation MAVEContactIdentifierBase

+ (NSString *)ownTypeName {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithValue:(NSString *)value {
    if (self = [super init]) {
        self.typeName = [[self class] ownTypeName];
        self.value = value;
    }
    return self;
}

- (NSString *)humanReadableValue {
    return self.value;
}

@end
