//
//  MAVEInviteSender.m
//  MaveSDK
//
//  Created by Danny Cosson on 7/31/15.
//
//

#import "MAVEInviteSender.h"
#import "MaveSDK.h"

@implementation MAVEInviteSender

- (void)invitePerson:(MAVEABPerson *)person withCompletionBlock:(void (^)(BOOL success))completionBlock {
    [person selectBestContactIdentifierIfNoneSelected];
    MaveSDK *mave = [MaveSDK sharedInstance];
    NSArray *recipients = @[person];
    [mave.APIInterface sendInvitesToRecipients:recipients smsCopy:mave.defaultSMSMessageText senderUserID:mave.userData.userID inviteLinkDestinationURL:mave.userData.inviteLinkDestinationURL wrapInviteLink:mave.userData.wrapInviteLink customData:mave.userData.customData completionBlock:^(NSError *error, NSDictionary *responseData) {
        BOOL ok = YES;
        if (error) {
            ok = NO;
        }
        completionBlock(ok);
    }];
}

@end