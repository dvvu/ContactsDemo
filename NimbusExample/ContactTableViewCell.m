//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactCellObject.h"
#import "ContactEntity.h"
#import "ContactCache.h"

@implementation ContactTableViewCell

#pragma mark - init TableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
   
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
    if (self) {
        
        _name = [[UILabel alloc] init];
        _profileImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_name];
        [self.contentView addSubview:_profileImage];
        [self setupLayoutForCell];
    }
    
    return self;
}

#pragma mark - selected cell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

#pragma mark - delegate oif NICell -> change when something is changed in cell

- (BOOL)shouldUpdateCellWithObject:(id)object {
    
    ContactEntity* contactEntity = [(ContactCellObject *)object contact];
    _name.text = contactEntity.name;
    _profileImage.image = contactEntity.profileImageDefault;
    
    [[ContactCache sharedInstance] getImageForKey:contactEntity.identifier completionWith:^(UIImage* image) {
        
        if (image) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                _profileImage.image = image;
            });
        }
        
    }];

    return YES;
}

#pragma mark - update layout

- (void)setupLayoutForCell {
    
    // ProfileImage
    _profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center Y
    [[_profileImage.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    
    // Height = 0.9 parent View
    [_profileImage addConstraint:[NSLayoutConstraint
                                  constraintWithItem:_profileImage
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1
                                  constant:self.contentView.frame.size.height * 0.9]];
    // Ratio = 1
    [_profileImage addConstraint:[NSLayoutConstraint
                                  constraintWithItem:_profileImage
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:_profileImage
                                  attribute:NSLayoutAttributeWidth
                                  multiplier:1
                                  constant:0]];
    // Space to left = 8
    NSLayoutConstraint* leftProfileImageConstraint = [NSLayoutConstraint
                                                 constraintWithItem:_profileImage
                                                 attribute:NSLayoutAttributeLeft
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                                 attribute: NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                 constant:8];
    
    [self.contentView addConstraints:@[leftProfileImageConstraint]];
    
    // Name
    _name.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center Y
    [[_name.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    
    // Space to _profileImage left = 8
    NSLayoutConstraint* leftNameConstraint = [NSLayoutConstraint
                                                 constraintWithItem:_name
                                                 attribute:NSLayoutAttributeLeft
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:_profileImage
                                                 attribute: NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                 constant:self.contentView.frame.size.height * 0.9 + 8];
    // Space to right = 8
    NSLayoutConstraint* rightNameConstraint = [NSLayoutConstraint
                                              constraintWithItem:_name
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.contentView
                                              attribute: NSLayoutAttributeRight
                                              multiplier:1.0
                                              constant:8];
    
    [self.contentView addConstraints:@[leftNameConstraint,rightNameConstraint]];
    
}

@end
