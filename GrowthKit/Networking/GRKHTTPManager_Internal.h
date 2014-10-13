//
//  GRKHTTPManager_Internal.h
//  GrowthKit
//
//  Created by dannycosson on 10/13/14.
//
//

#import <Foundation/Foundation.h>
#import "GRKHTTPManager.h"

@interface GRKHTTPManager ()

+ (NSDictionary *)defaultHeaders;

// Send a JSON request to GrowthKit API, identified by the application ID
// Will serialize & deserialize to/from JSON to pass the data
- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                    params:(NSDictionary *)params
                           completionBlock:(GRKHTTPCompletionBlock)completionBlock;

+ (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(GRKHTTPCompletionBlock)completionBlock;

@end