//
//  MAVEContactsInvitePageV2TableViewCell2.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import "MAVEContactsInvitePageV2TableViewCell2.h"

@implementation MAVEContactsInvitePageV2TableViewCell2

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super initWithCoder:aDecoder]) {
//        NSLog(@"initwithcoder");
//        [self doInitialSetup];
//    }
//    return self;
//}
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
//        NSLog(@"init with style");
//        [self doInitialSetup];
//    }
//    return self;
//}

- (void)doInitialSetup {
    self.nameLabel.text = @"FOo";
}

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"awoke");
    [self doInitialSetup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
