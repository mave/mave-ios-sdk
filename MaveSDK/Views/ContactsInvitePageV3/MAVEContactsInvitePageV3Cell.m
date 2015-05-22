//
//  MAVEContactsInvitePageV3Cell.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEContactsInvitePageV3Cell.h"

@implementation MAVEContactsInvitePageV3Cell {
    BOOL _didSetupInitialConstraints;
}

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInitialSetup];
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor redColor];
    self.picture = [[UIImageView alloc] init];
    self.picture.translatesAutoresizingMaskIntoConstraints = NO;
    self.picture.backgroundColor = [UIColor grayColor];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.text = @"Foo Bar";

    self.checkmarkBox = [[MAVECustomCheckboxV3 alloc] init];
    self.checkmarkBox.translatesAutoresizingMaskIntoConstraints = NO;

    self.contactInfoContainerView = [[UIView alloc] init];
    self.contactInfoContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.picture];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.checkmarkBox];
//    [self.contentView addSubview:self.contactInfoContainerView];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    NSDictionary *metrics = @{@"pictureHeight": @30};
    NSDictionary *viewsWithSelf = NSDictionaryOfVariableBindings(self.picture, self.nameLabel, self.checkmarkBox, self.contactInfoContainerView);
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:[viewsWithSelf count]];
    for (NSString *key in viewsWithSelf) {
        NSString *newKey = [key stringByReplacingOccurrencesOfString:@"self." withString:@""];
        [tmp setObject:[viewsWithSelf objectForKey:key] forKey:newKey];
    }
    
    NSDictionary *views = [NSDictionary dictionaryWithDictionary:tmp];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[picture(==pictureHeight)]-8-[nameLabel]-8-[checkmarkBox(==20)]-8-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[picture(==pictureHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[nameLabel]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[checkmarkBox(==20)]" options:0 metrics:metrics views:views]];
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}



@end
