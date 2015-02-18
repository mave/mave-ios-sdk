//
//  MAVERemoteConfigurationContactSync.h
//  MaveSDK
//
//  Created by Danny Cosson on 2/18/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"


@interface MAVERemoteConfigurationContactsSync : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) BOOL enabled;

+ (NSDictionary *)defaultJSONData;

@end
