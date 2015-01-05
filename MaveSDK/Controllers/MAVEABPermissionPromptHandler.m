//
//  MAVEAddressBookPromptHandler.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <AddressBook/AddressBook.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVEABCollection.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEAPIInterface.h"


@implementation MAVEABPermissionPromptHandler

// Prompt for contacts permissions. Based on remote configuration settings, we may show a
// pre-prompt UIAlertView (i.e. double prompt for contacts), and if so the copy can come
// from remote configuration as well.
- (void)promptForContactsWithCompletionBlock:(void (^)(NSDictionary *))completionBlock {
    [[MaveSDK sharedInstance].remoteConfigurationBuilder
            initializeObjectWithTimeout:2.0 completionBlock:^(id obj) {

        MAVERemoteConfiguration *remoteConfig = obj;
        self.prePromptTemplate = remoteConfig.contactsPrePromptTemplate;
        self.completionBlock = completionBlock;

        if (remoteConfig.enableContactsPrePrompt) {
            // purposely create retain cycle so it won't get dealloc'ed until alert view
            // is displayed then dismissed
            self.retainSelf = self;

            [self logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionPromptView];
            
            [self showPrePromptAlertWithTitle:self.prePromptTemplate.title
                                      message:self.prePromptTemplate.message
                             cancelButtonCopy:self.prePromptTemplate.cancelButtonCopy
                             acceptbuttonCopy:self.prePromptTemplate.acceptButtonCopy];

        } else {
            [self logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionPromptView];
            [self loadAddressBookAndComplete];
        }
    }];
}


- (void)loadAddressBookAndComplete {
    // Loads the address book, prompting user if user has not been prompted yet, and
    // calls the completion block with the data (or with nil if permission denied)
    CFErrorRef accessError;
    ABAddressBookRef addressBook = [self getABAddressBookRef:accessError];
    if (accessError != nil) {
        self.completionBlock(nil);
    }

    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        NSArray *maveABPersons;
        if (granted) {
            NSArray *addressBookNS = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            maveABPersons = [MAVEABCollection copyEntireAddressBookToMAVEABPersonArray:addressBookNS];
        } else {
            DebugLog(@"User denied address book permission!");
        }
        if (addressBook != NULL) CFRelease(addressBook);
        NSDictionary *indexedABPersons =
            [MAVEABCollection indexedDictionaryFromMAVEABPersonArray:maveABPersons];
        self.completionBlock(indexedABPersons);
    });
}

- (ABAddressBookRef)getABAddressBookRef:(CFErrorRef)accessErrorCF {
    // Wrapper around calling the CF function to create an address book object.
    // Calls the completion block with nil if there's a problem
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &accessErrorCF);
    if (accessErrorCF != nil) {
        NSError *abAccessError = (__bridge_transfer NSError *)accessErrorCF;
        if (!([abAccessError.domain isEqualToString:@"ABAddressBookErrorDomain"]
              && abAccessError.code == 1)) {
            DebugLog(@"Unknown Error getting address book");
        }
    }
    return addressBook;
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
- (void)logContactsPromptRelatedEventWithRoute:(NSString *)route {
    NSDictionary *params = nil;
    if (self.prePromptTemplate.templateID) {
        params = @{MAVEAPIParamPrePromptTemplateID:
                       self.prePromptTemplate.templateID};
    }
    [[MaveSDK sharedInstance].APIInterface trackGenericUserEventWithRoute:route
                                                         additionalParams:params];
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
        [self loadAddressBookAndComplete];
    }
}

@end
