//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "NimbusModels.h"
#import <UIKit/UIKit.h>
#import "NimbusCore.h"

@interface ContactTableViewCell : UITableViewCell <NICell>

@property (nonatomic, strong) UIImageView* profileImageView;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) UILabel* nameLabel;

@end

