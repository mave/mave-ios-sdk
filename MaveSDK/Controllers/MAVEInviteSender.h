//
//  MAVEInviteSender.h
//  MaveSDK
//
//  Created by Danny Cosson on 7/31/15.
//
//

#import "MAVEABPerson.h"

@interface MAVEInviteSender : NSObject

- (void)invitePerson:(MAVEABPerson *)person withCompletionBlock:(void (^)(BOOL success))completionBlock;

@end
