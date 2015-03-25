//
//  MAVERemoteConfigurationClientShare.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVERemoteConfigurationClientSMS : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *textTemplate;
- (NSString *)text;

+ (NSDictionary *)defaultJSONData;

@end
