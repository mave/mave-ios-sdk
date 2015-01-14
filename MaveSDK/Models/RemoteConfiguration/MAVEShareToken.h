//
//  MAVEShareToken.h
//  MaveSDK
//
//  Object to hold the share token, which is the equivalent of a link for a client-side
//  invite or share (since for server-side invites we generate and append right when sending)
//
//  This is separate from the main remote configuration object because it needs to be a unique
//  token generated for this device and we don't want to refresh it every time the app opens b/c
//  that would increase server load and leave a bunch of tokens unused for no reason.
//
//  Created by Danny Cosson on 1/7/15.
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVEShareToken : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, copy) NSString *shareToken;

+ (MAVERemoteObjectBuilder *)remoteBuilder;
+ (NSDictionary *)defaultJSONData;
+ (void)clearUserDefaults;

@end