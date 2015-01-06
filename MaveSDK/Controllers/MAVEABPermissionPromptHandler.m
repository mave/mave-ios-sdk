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
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEAPIInterface.h"


@implementation MAVEABPermissionPromptHandler

- (instancetype)initCustom {
    // Override init method so we can stub it in tests
    return [super init];
}

// Prompt for contacts permissions. Based on remote configuration settings, we may show a
// pre-prompt UIAlertView (i.e. double prompt for contacts), and if so the copy can come
// from remote configuration as well.
+ (void)promptForContactsWithCompletionBlock:(void (^)(NSDictionary *))completionBlock {
    MAVEABPermissionPromptHandler *this = [[[self class] alloc] init];
    this.completionBlock = completionBlock;
    NSString *abStatus = [MAVEABUtils addressBookPermissionStatus];

    // If permission already denied, abort early
    if ([abStatus isEqualToString:MAVEABPermissionStatusDenied]) {
        [this completeAfterPermissionDenied];
        return;
    }

    // If permission already granted, just load the address book
    if ([abStatus isEqualToString:MAVEABPermissionStatusAllowed]) {
        [this loadAddressBookAndComplete];
        return;
    }

    // Otherwise, decide how to prompt and prompt
    [[MaveSDK sharedInstance].remoteConfigurationBuilder
            initializeObjectWithTimeout:2.0 completionBlock:^(id obj) {

        MAVERemoteConfiguration *remoteConfig = obj;
        this.prePromptTemplate = remoteConfig.contactsPrePromptTemplate;

        if (remoteConfig.enableContactsPrePrompt) {
            // purposely create retain cycle so it won't get dealloc'ed until alert view
            // is displayed then dismissed
            this.retainSelf = self;

            [this logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionPromptView];
            
            [this showPrePromptAlertWithTitle:this.prePromptTemplate.title
                                      message:this.prePromptTemplate.message
                             cancelButtonCopy:this.prePromptTemplate.cancelButtonCopy
                             acceptbuttonCopy:this.prePromptTemplate.acceptButtonCopy];

        } else {
            [this logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionPromptView];
            [this loadAddressBookAndComplete];
        }
    }];
}


- (void)loadAddressBookAndComplete {
    // Loads the address book, prompting user if user has not been prompted yet, and
    // calls the completion block with the data (or with nil if permission denied)
    //
    // This method will have to just be tested as part of the integration/UI tests in actually
    // loading up an address book, it's more trouble than it's worth to stub out the CF functions
    //
    CFErrorRef accessErrorCF;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &accessErrorCF);
    if (accessErrorCF != nil) {
        NSError *abAccessError = (__bridge_transfer NSError *)accessErrorCF;
        DebugLog(@"Error creating address book domain: %@ code: %ld",
                 abAccessError.domain, (long)abAccessError.code);
        if (addressBook != NULL) CFRelease(addressBook);
        [self completeAfterPermissionDenied];
        return;
    }

    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSArray *addressBookNS = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            NSArray *maveABPersons = [MAVEABUtils copyEntireAddressBookToMAVEABPersonArray:addressBookNS];
            if (addressBook != NULL) CFRelease(addressBook);
            [self completeAfterPermissionGranted:maveABPersons];
        } else {
            if (addressBook != NULL) CFRelease(addressBook);
            [self completeAfterPermissionDenied];
        }
    });
}

- (void)completeAfterPermissionGranted:(NSArray *)MAVEABPersonsArray {
    DebugLog(@"User accepted address book permissions");
    [self logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionGranted];
    NSDictionary *indexedPersons = [MAVEABUtils indexedDictionaryFromMAVEABPersonArray:MAVEABPersonsArray];
    self.completionBlock(indexedPersons);
}

- (void)completeAfterPermissionDenied {
    DebugLog(@"User denied address book permissions");
    [self logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPermissionDenied];
    self.completionBlock(nil);
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

# pragma mark - pre prompt related Methods

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

// Respond to pre-prompt response
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // let self get GC'd, this is a one-time use object
    self.retainSelf = nil;

    // clicked cancel
    if (buttonIndex == 0) {
        [self logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionDenied];
        self.completionBlock(nil);

    // clicked accept
    } else {
        [self logContactsPromptRelatedEventWithRoute:MAVERouteTrackContactsPrePermissionGranted];
        [self loadAddressBookAndComplete];
    }
}

@end
