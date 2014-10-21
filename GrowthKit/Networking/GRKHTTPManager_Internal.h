//
//  GRKHTTPManager_Internal.h
//  GrowthKit
//
//  Created by dannycosson on 10/14/14.
//
//

#ifndef GrowthKit_GRKHTTPManager_Internal_h
#define GrowthKit_GRKHTTPManager_Internal_h


#endif

#import <Foundation/Foundation.h>
#import "GRKHTTPManager.h"

@interface GRKHTTPManager ()

@property Class NSJSONSerialization;

// Send a JSON request to GrowthKit API, identified by the application ID
// Will serialize & deserialize to/from JSON to pass the data
- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodType:(NSString *)methodType
                                    params:(NSDictionary *)params
                           completionBlock:(GRKHTTPCompletionBlock)completionBlock;

+ (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(GRKHTTPCompletionBlock)completionBlock;


@end