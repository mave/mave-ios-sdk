//
//  MAVEAddressBookPromptHandler.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MaveSDK.h"
#import "MAVEABCollection.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEHTTPManager.h"
#import "MAVERemoteConfiguration.h"


const NSString *MAVEEventRouteContactsPrePermissionPromptView = @"/events/contacts_pre_permission_prompt_view";
const NSString *MAVEEventRouteContactsPrePermissionGranted = @"/events/contacts_pre_permission_granted";
const NSString *MAVEEventRouteContactsPrePermissionDenied = @"/events/contacts_pre_permission_denied";
const NSString *MAVEEventRouteContactsPermissionPromptView = @"/events/contacts_permission_prompt_view";
const NSString *MAVEEventRouteContactsPermissionGranted = @"/events/contacts_permission_granted";
const NSString *MAVEEventRouteContactsPermissionDenied = @"/events/contacts_permission_granted";



@implementation MAVEABPermissionPromptHandler

// Prompt for contacts permissions. Based on remote configuration settings, we may show a
// pre-prompt UIAlertView (i.e. double prompt for contacts), and if so the copy can come
// from remote configuration as well.
- (void)promptForContactsWithCompletionBlock:(void (^)(NSDictionary *))completionBlock {
    [[MaveSDK sharedInstance].remoteConfigurationBuilder
            initializeObjectWithTimeout:2.0 completionBlock:^(id obj) {

        MAVERemoteConfiguration *remoteConfig = obj;
        MAVERemoteConfigurationContactsPrePromptTemplate *tmpl = remoteConfig.contactsPrePromptTemplate;
        self.prePromptTemplateID = tmpl.templateID;

        if (remoteConfig.enableContactsPrePrompt) {
            self.completionBlock = completionBlock;
            // purposely create retain cycle so it won't get dealloc'ed until alert view
            // is displayed then dismissed
            self.retainSelf = self;
            
            [self showPrePromptAlertWithTitle:tmpl.title
                                      message:tmpl.message
                             cancelButtonCopy:tmpl.cancelButtonCopy
                             acceptbuttonCopy:tmpl.acceptButtonCopy];

        } else {
            [MAVEABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
                completionBlock(indexedData);
            }];
        }
    }];
}

- (void)showPrePromptAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                   cancelButtonCopy:(NSString *)cancelButtonCopy
                   acceptbuttonCopy:(NSString *)acceptButtonCopy {
    UIAlertView *prePrompt = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonCopy
                                              otherButtonTitles:acceptButtonCopy, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [prePrompt show];
    });
}

// Tracking events
//- (void)logContactsPromptRelatedEvent:(NSString *)eventRoute
//                  prePromptTemplateID:(NSString *)templateID {
//    NSMutableDictionary *params = (NSMutableDictionary *)[[MaveSDK sharedInstance].userData toDictionaryIDOnly];
//    
//    [[MaveSDK sharedInstance].HTTPManager sendIdentifiedJSONRequestWithRoute:eventRoute
//                                                                  methodType:@"POST"
//                                                                      params:params
//                                                             completionBlock:nil];
//    
//}

# pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // let self get GC'd, this is a one-time use object
    self.retainSelf = nil;

    // clicked cancel
    if (buttonIndex == 0) {
        self.completionBlock(nil);

    // clicked accept
    } else {
        [MAVEABCollection createAndLoadAddressBookWithCompletionBlock:^(NSDictionary *indexedData) {
            self.completionBlock(indexedData);
        }];
    }
}

@end
