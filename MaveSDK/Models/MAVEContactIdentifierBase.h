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

@property (nonatomic, assign) BOOL selected;

+ (NSString *)ownTypeName;
- (instancetype)initWithValue:(NSString *)value;
- (NSString *)humanReadableValue;
// If there's extra information to show e.g. the value plus a label, this method would return it
- (NSString *)humanReadableValueForDetailedDisplay;

- (NSComparisonResult)compareContactIdentifiers:(MAVEContactIdentifierBase *)other;

@end
