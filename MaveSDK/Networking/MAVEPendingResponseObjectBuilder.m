//
//  MAVEHTTPRequestObjectBuilder.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//

#import "MAVEConstants.h"
#import "MAVEPendingResponseObjectBuilder.h"
#import "MAVEPendingResponseData.h"

@implementation MAVEPendingResponseObjectBuilder

- (instancetype)initWithClass:(Class<MAVEDictionaryInitializable>)initializableClass
          pendingResponseData:(MAVEPendingResponseData *)pendingResponseData {
    if (self = [self init]) {
        self.initializableClass = initializableClass;
        self.pendingResponseData = pendingResponseData;
    }
    return self;
    
}

- (void)initializeObjectWithTimeout:(float)timeout completionBlock:(void (^)(id))completionBlock {
    [self.pendingResponseData readDataWithTimeout:timeout
                                  completionBlock:^(NSDictionary *responseData, NSDictionary *defaultData) {
        id returnObject;
        @try {
            // if responseData is malformed, this should return nil or raise exception
            returnObject = [[self.initializableClass alloc] initWithDictionary:responseData];
        }
        @catch (NSException *exception) {
            returnObject = nil;
        }
        if (!returnObject) {
            DebugLog(@"MAVEPendingResponseObjectBuilder fell back to default data");
            returnObject = [[self.initializableClass alloc] initWithDictionary:defaultData];
        }
        completionBlock(returnObject);
    }];
}
@end
