//
//  MAVEContactsInvitePageV2TableViewCell.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2TableViewCell.h"

@implementation MAVEContactsInvitePageV2TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)doInitialSetup {
    self.backgroundColor = [UIColor blueColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @"Foo bar";
    self.contactInfoLabel = [[UILabel alloc] init];
    self.contactInfoLabel.text = @"(808) 555-1234";

    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contactInfoLabel];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];

    NSLog(@"update constraints");
    NSString *vc = @"V:|-10-[nameLabel]-10-[contactInfoLabel]-10-|";
    NSString *hcNL = @"H:|-10-[nameLabel(>=0)]-10-|";
    NSString *hcCIL = @"H:|-10-[contactInfoLabel(>=0)]-10-|";
    NSDictionary *views = @{@"nameLabel": self.nameLabel,
                            @"contactInfoLabel": self.contactInfoLabel};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vc options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hcNL options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hcCIL options:0 metrics:nil views:views]];
}


- (void)layoutSubviews {

}

@end
