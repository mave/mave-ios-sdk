//
//  MAVEContactIdentifierBase.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/26/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEContactIdentifierBase : NSObject

@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSString *value;

+ (NSString *)ownTypeName;
- (instancetype)initWithValue:(NSString *)value;
- (NSString *)humanReadableValue;

- (NSComparisonResult)compareContactIdentifiers:(MAVEContactIdentifierBase *)other;

@end
