//
//  MAVESuggestedInviteReusableCellDelegate.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVESuggestedInviteReusableCellDelegate : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *startingIndexPath;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, strong) NSArray *liveData;
@property (nonatomic, strong) NSArray *standbyData;

- (instancetype)initForTableView:(UITableView *)tableView
               startingIndexPath:(NSIndexPath *)startingIndexPath
                    numberOfRows:(NSInteger)numberOfRows;

@end
