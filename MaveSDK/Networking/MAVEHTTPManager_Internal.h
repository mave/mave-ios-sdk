//
//  MAVEHTTPManager_Internal.h
//  MaveSDK
//
//  Created by dannycosson on 10/14/14.
//
//

#ifndef MaveSDK_MAVEHTTPManager_Internal_h
#define MaveSDK_MAVEHTTPManager_Internal_h


#endif

#import <Foundation/Foundation.h>
#import "MAVEHTTPManager.h"

@interface MAVEHTTPManager ()

@property Class NSJSONSerialization;

// Send a JSON request to MaveSDK API, identified by the application ID
// Will serialize & deserialize to/from JSON to pass the data
- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodType:(NSString *)methodType
                                    params:(NSDictionary *)params
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

+ (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(MAVEHTTPCompletionBlock)completionBlock;


@end