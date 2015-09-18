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
// Country Codes are the 2-letter codes for the countries in which we
// support sending server-side SMS messages. If the locale country of
// the user's device matches one of the codes returned here, any sms
// messages sent will be server-side. Otherwise we will take the user
// to the client sms compose screen
@property (nonatomic, copy) NSSet *countryCodes;
- (NSString *)text;

+ (NSDictionary *)defaultJSONData;

@end
