//
//  MAVEContactIdentifierWithLabelBase.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import "MAVEContactIdentifierBase.h"

@interface MAVEContactIdentifierWithLabelBase : MAVEContactIdentifierBase

@property (nonatomic, strong) NSString *label;

- (instancetype)initWithValue:(NSString *)value andLabel:(NSString *)label;
- (NSString *)humanReadableLabel;

@end
