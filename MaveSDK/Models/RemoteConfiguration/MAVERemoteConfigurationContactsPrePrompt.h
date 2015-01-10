//
//  MAVERemoteConfigurationContactsPrePrompt.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVERemoteConfigurationContactsPrePrompt : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) BOOL enabled;

@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *cancelButtonCopy;
@property (nonatomic, copy) NSString *acceptButtonCopy;

+ (NSDictionary *)defaultJSONData;

@end
