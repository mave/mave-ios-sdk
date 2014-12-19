//
//  MAVERemoteConfiguration.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVERemoteConfiguration.h"
#import "MAVEHTTPManager.h"

@implementation MAVERemoteConfiguration

- (instancetype)initWithJSON:(NSDictionary *)responseData {
    if (self = [self init]) {
        
    }
    return self;
}

// JSON-formatted data to initiate the remote configuration in its default state
+ (NSDictionary *)defaultJSONData {
    NSDictionary *defaults = [[NSDictionary alloc] init];
    return defaults;
}

@end
