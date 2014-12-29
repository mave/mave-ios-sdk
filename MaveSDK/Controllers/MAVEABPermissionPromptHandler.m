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
#import "MAVERemoteConfiguration.h"

@implementation MAVEABPermissionPromptHandler

// Prompt for contacts permissions. Based on remote configuration settings, we may show a
// pre-prompt UIAlertView (i.e. double prompt for contacts), and if so the copy can come
// from remote configuration as well.
+ (void)promptForContactsWithCompletionBlock:(void (^)(NSDictionary *))completionBlock {
    [[MaveSDK sharedInstance].remoteConfigurationBuilder
            initializeObjectWithTimeout:2.0 completionBlock:^(id obj) {

        MAVERemoteConfiguration *remoteConfig = obj;
        MAVERemoteConfigurationContactsPrePromptTemplate *tmpl = remoteConfig.contactsPrePromptTemplate;

        if (remoteConfig.enableContactsPrePrompt) {
            MAVEABPermissionPromptHandler *this = [[self alloc] init];
            this.completionBlock = completionBlock;
            // purposely create retain cycle so it won't get dealloc'ed until alert view
            // is displayed then dismissed
            this.retainSelf = this;
            
            [this showPrePromptAlertWithTitle:tmpl.title
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
