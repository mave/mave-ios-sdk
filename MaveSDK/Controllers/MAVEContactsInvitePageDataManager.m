//
//  MAVEContactsInvitePageDataManager.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import "MAVEContactsInvitePageDataManager.h"
#import "MaveSDK.h"
#import "MAVEABUtils.h"

// This is UTF-8 code point 0021, it should get sorted before any letters in any language
NSString * const MAVESuggestedInvitesTableDataKey2 = @"\u2605";
// This is the last UTF-8 printable character, it should get sorted after any letters in any language
NSString * const MAVENonAlphabetNamesTableDataKey2 = @"\uffee";

@implementation MAVEContactsInvitePageDataManager

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
}

- (NSArray *)sectionIndexesForMainTable {
    return [self.mainTableData allKeys];
}
- (NSInteger)numberOfSectionsInMainTable {
    return [[self sectionIndexesForMainTable] count];
}
- (NSInteger)numberOfRowsInMainTableSection:(NSUInteger)section {
    NSString *sectionKey = [[self sectionIndexesForMainTable] objectAtIndex:section];
    NSArray *rows = [self.mainTableData objectForKey:sectionKey];
    return [rows count];
}

- (MAVEABPerson *)personAtMainTableIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [[self sectionIndexesForMainTable] objectAtIndex:indexPath.section];
    NSArray *rows = [self.mainTableData objectForKey:sectionKey];
    return [rows objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathOfFirstOccuranceInMainTableOfPerson:(MAVEABPerson *)person {
    NSNumber *personKey = [NSNumber numberWithInteger:person.recordID];
    return [[self.personToIndexPathsIndex objectForKey:personKey] objectAtIndex:0];
}

- (MAVEABPerson *)personAtSearchTableIndexPath:(NSIndexPath *)indexPath {
    // TODO: implement
    return nil;
}

- (void)setMainTableData:(NSDictionary *)mainTableData {
    _mainTableData = mainTableData;
    [self updateMainTablePersonToIndexPathsIndex];
}

- (void)updateMainTablePersonToIndexPathsIndex {
    NSNumber *personKey;
    NSIndexPath *idxPath; NSInteger sectionIdx = 0, rowIdx = 0;
    NSMutableDictionary *index = [[NSMutableDictionary alloc] init];
    for (NSString *sectionKey in [self sectionIndexesForMainTable]) {
        rowIdx = 0;
        for (MAVEABPerson *person in [self.mainTableData objectForKey:sectionKey]) {
            personKey = [NSNumber numberWithInteger:person.recordID];
            idxPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
            if (![index objectForKey:personKey]) {
                [index setObject:[[NSMutableArray alloc] init] forKey:personKey];
            }
            [[index objectForKey:personKey] addObject:idxPath];
            rowIdx++;
        }
        sectionIdx++;
    }
    self.personToIndexPathsIndex = index;
}

- (void)updateWithContacts:(NSArray *)contacts ifNecessaryAsyncSuggestionsBlock:(void (^)(NSArray *))asyncSuggestionsBlock {
    NSDictionary *indexedContactsToRenderNow;
    BOOL updateSuggestionsWhenReady = NO;
    [[self class] buildContactsToUseAtPageRender:&indexedContactsToRenderNow
                      addSuggestedLaterWhenReady:&updateSuggestionsWhenReady
                                fromContactsList:contacts];
    self.mainTableData = indexedContactsToRenderNow;
    
    if (updateSuggestionsWhenReady && asyncSuggestionsBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *suggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:10];
            dispatch_async(dispatch_get_main_queue(), ^{
                asyncSuggestionsBlock(suggestions);
            });
        });
    }
}

+ (void)buildContactsToUseAtPageRender:(NSDictionary **)suggestedContactsReturnVal
            addSuggestedLaterWhenReady:(BOOL *)addSuggestedLaterReturnVal
                      fromContactsList:(NSArray *)contacts {
    BOOL suggestionsEnabled = [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.suggestedInvitesEnabled;
    if (!suggestionsEnabled) {
        *suggestedContactsReturnVal = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
        *addSuggestedLaterReturnVal = NO;
        return;
    }
    BOOL suggestionsReady = [MaveSDK sharedInstance].suggestedInvitesBuilder.promise.status != MAVEPromiseStatusUnfulfilled;
    if (!suggestionsReady) {
        NSDictionary *indexedContacts = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
        *suggestedContactsReturnVal = [MAVEABUtils combineSuggested:@[] intoABIndexedForTableSections:indexedContacts];
        *addSuggestedLaterReturnVal = YES;
        return;
    }

    NSArray *suggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:0];
    NSDictionary *indexedContacts = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
    if ([suggestions count] > 0) {
        *suggestedContactsReturnVal = [MAVEABUtils combineSuggested:suggestions intoABIndexedForTableSections:indexedContacts];
    } else {
        *suggestedContactsReturnVal = indexedContacts;
    }
    *addSuggestedLaterReturnVal = NO;
}



@end
