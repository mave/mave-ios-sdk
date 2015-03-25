//
//  MAVERemoteConfigurationServerSMS.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/14/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVERemoteConfigurationServerSMS : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *textTemplate;
- (NSString *)smsCopy;

+ (NSDictionary *)defaultJSONData;

@end
