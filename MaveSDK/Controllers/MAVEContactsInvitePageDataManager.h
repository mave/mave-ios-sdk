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

@interface MAVEContactsInvitePageDataManager : NSObject

@property (nonatomic, strong) NSDictionary *mainTableData;
@property (nonatomic, strong) NSArray *searchTableData;

- (NSArray *)sectionIndexesForMainTable;
- (NSString *)sectionTitleForMainTableSection:(NSUInteger)section;

- (MAVEABPerson *)personAtMainTableIndexPath:(NSIndexPath *)indexPath;
- (MAVEABPerson *)personAtSearchTableIndexPath:(NSIndexPath *)indexPath;

@end
