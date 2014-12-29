//
//  MAVEHTTPRequestObjectBuilder.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//  Instantiates an object from response of an http request.
//
//

#import <Foundation/Foundation.h>
#import "MAVEPendingResponseData.h"

@protocol MAVEDictionaryInitializable <NSObject>
+ (instancetype)alloc;
- (instancetype)initWithDictionary:(NSDictionary *)data;
@end



@interface MAVEPendingResponseObjectBuilder : NSObject

@property (nonatomic, strong) Class<MAVEDictionaryInitializable> initializableClass;
@property (nonatomic, strong) MAVEPendingResponseData *pendingResponseData;

// Initializing the object builder pre-fetches the request with which to build the object
- (instancetype)initWithClass:(Class<MAVEDictionaryInitializable>)initializableClass
          pendingResponseData:(MAVEPendingResponseData *)pendingResponseData;
- (void)initializeObjectWithTimeout:(float)timeout completionBlock:(void(^)(id))completionBlock;

@end
