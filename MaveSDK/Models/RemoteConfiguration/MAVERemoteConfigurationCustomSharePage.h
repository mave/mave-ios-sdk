//
//  MAVERemoteConfigurationCustomSharePage.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/13/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVERemoteConfigurationCustomSharePage : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) BOOL enabled;
@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *explanationCopyTemplate;
- (NSString *)explanationCopy;

+ (NSDictionary *)defaultJSONData;

@end
