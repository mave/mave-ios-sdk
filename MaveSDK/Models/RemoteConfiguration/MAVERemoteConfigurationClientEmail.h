//
//  MAVERemoteConfigurationClientEmail.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVERemoteConfigurationClientEmail : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *subjectTemplate;
- (NSString *)subject;
@property (nonatomic, copy) NSString *bodyTemplate;
- (NSString *)body;

+ (NSDictionary *)defaultJSONData;

@end
