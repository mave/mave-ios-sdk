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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.nameLabel.text = @"Foo Bar";
    self.contactInfoLabel.text = @"foo@foo.com";

    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitle:@"Send" forState:UIControlStateHighlighted];
    [self.sendButton setTitle:@"Sent!" forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(foo) forControlEvents:UIControlEventTouchUpInside];

    self.expandedContactInfoHeightConstraint.constant = 0;
}

- (void)foo {
    NSLog(@"hi");
    self.sendButton.enabled = NO;
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
