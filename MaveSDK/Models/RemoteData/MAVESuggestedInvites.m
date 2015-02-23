//
//  MAVESuggestedInvites.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/20/15.
//
//

#import "MAVESuggestedInvites.h"
#import "MAVERemoteObjectBuilder.h"
#import "MAVERemoteObjectBuilder_Internal.h"

const NSString *MAVESuggestedInvitesKeyClosestContacts = @"closest_contacts";

@implementation MAVESuggestedInvites

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSArray *closest = [data objectForKey:MAVESuggestedInvitesKeyClosestContacts];
        if (!closest || (id)closest == [NSNull null]) {
            return nil;
        }
        self.suggestions = closest;
    }
    return self;
}

+ (MAVERemoteObjectBuilder *)remoteBuilder {
    MAVERemoteObjectBuilder *remoteBuilder = [[MAVERemoteObjectBuilder alloc] init];
    remoteBuilder.classToCreate = [self class];
    remoteBuilder.promise = [[MAVEPromise alloc] initWithBlock:nil];
    remoteBuilder.defaultData = [[self class] defaultData];
    return remoteBuilder;
}

+ (NSDictionary *)defaultData {
    return @{MAVESuggestedInvitesKeyClosestContacts: @[]};
}

@end
