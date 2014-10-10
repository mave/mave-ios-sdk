//
//  GRKNetworkController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRKNetworkController : NSObject

- (void)sendInvitesWithSuccessCallback:(void(^)(NSUInteger *))successBlock failureCallback:(void(^)(NSError *))errorBlock;

@end
