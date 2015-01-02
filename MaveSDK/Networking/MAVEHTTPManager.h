//
//  MAVEHTTPManager.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAVEUserData.h"
#import "MAVEPendingResponseData.h"

typedef void (^MAVEHTTPCompletionBlock)(NSError *error, NSDictionary *responseData);


@interface MAVEHTTPManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, copy) NSString *applicationID;
@property (nonatomic, copy) NSString *applicationDeviceID;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, strong) NSURLSession *session;

// UserAgent & screenSize are for fingerprinting
+ (NSString *)userAgentWithUIDevice:(UIDevice *)device;
+ (NSString *)formattedScreenSize:(CGSize)size;


- (instancetype)initWithApplicationID:(NSString *)applicationID
                  applicationDeviceID:(NSString *)applicationDeviceID;

// API request methods
- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodType:(NSString *)methodType
                                    params:(NSDictionary *)params
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

- (MAVEPendingResponseData *) preFetchIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                                          methodType:(NSString *)methodType
                                                              params:(NSDictionary *)params
                                                         defaultData:(NSDictionary *)defaultResponse;

+ (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

+ (NSString *)dictToURLQueryStringFragment:(NSDictionary *)dict;


// Specific API Requests the app will make
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
                        userId:(NSString *)userId
      inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
               completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

- (void)trackAppOpenRequest;
- (void)identifyUserRequest:(MAVEUserData *)userData;
- (void)trackSignupRequest:(MAVEUserData *)userData;
- (void)trackInvitePageOpenRequest:(MAVEUserData *)userData
                          pageType:(NSString *)invitePageType;
- (void)getReferringUser:(void (^)(MAVEUserData *userData))referringUserBlock;
- (MAVEPendingResponseData *)preFetchRemoteConfiguration:(NSDictionary *)defaultData;

@end