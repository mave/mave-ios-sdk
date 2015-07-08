//
//  MAVEContactsInvitePageDataManager.h
//  MaveSDK
//
//  This class holds the data and keeps the indexes for accessing it in various ways,
//  as well as helpers for searching. Returns most of the fields the data source/delegate
//  methods for the table will use.
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"

extern NSString * const MAVESuggestedInvitesTableDataKey;
extern NSString * const MAVENonAlphabetNamesTableDataKey;

@interface MAVEContactsInvitePageDataManager : NSObject

@property (nonatomic, strong) NSDictionary *mainTableData;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *mainTableSectionKeys;
@property (nonatomic, strong) NSDictionary *personToIndexPathsIndex;
@property (nonatomic, strong) NSArray *searchTableData;

- (NSArray *)sectionIndexesForMainTable;
+ (NSArray *)sortedSectionKeys:(NSArray *)sectionKeys;
- (NSInteger)numberOfSectionsInMainTable;
- (NSInteger)numberOfRowsInMainTableSection:(NSUInteger)section;

- (MAVEABPerson *)personAtMainTableIndexPath:(NSIndexPath *)indexPath;
- (MAVEABPerson *)personAtSearchTableIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfFirstOccuranceInMainTableOfPerson:(MAVEABPerson *)person;


// Method to update the table data with the given contacts, and if suggestions were not yet returned
// wait for them and then call the given block for updating them asynchronously (i.e. animating them in).
// If suggestions were already returned, they just get loaded with contacts and the async block is not called.
- (void)updateWithContacts:(NSArray *)contacts
ifNecessaryAsyncSuggestionsBlock:(void(^)(NSArray *suggestions))asyncSuggestionsBlock
   noSuggestionsToAddBlock:(void(^)())noSuggestionsBlock;

// Helper to manipulate contacts to also show suggested invites.
// Based on the current state, we might
//   - already have suggestions to display
//   - already know we don't have suggestions to display
//   - still be waiting for api response to return 0 or more suggestions
+ (void)buildContactsToUseAtPageRender:(NSDictionary **)suggestedContactsReturnVal
            addSuggestedLaterWhenReady:(BOOL *)addSuggestedLaterReturnVal
                      fromContactsList:(NSArray *)contacts;

@end
