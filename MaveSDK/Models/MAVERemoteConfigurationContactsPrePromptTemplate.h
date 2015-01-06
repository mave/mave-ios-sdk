//
//  MAVERemoteConfigurationContactsPrePromptTemplate.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import "MAVEPendingResponseObjectBuilder.h"

@interface MAVERemoteConfigurationContactsPrePromptTemplate : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, strong) NSString *templateID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancelButtonCopy;
@property (nonatomic, strong) NSString *acceptButtonCopy;

+ (NSDictionary *)defaultJSONData;

@end
