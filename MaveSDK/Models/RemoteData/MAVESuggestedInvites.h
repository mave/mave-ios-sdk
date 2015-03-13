//
//  MAVESuggestedInvites.h
//  MaveSDK
//
//  Created by Danny Cosson on 2/20/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVESuggestedInvites : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, strong) NSArray *suggestions;

+ (MAVERemoteObjectBuilder *)remoteBuilder;
+ (NSDictionary *)defaultData;

@end
