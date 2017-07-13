//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "NICellCatalog.h"

@interface ContactCellObject : NITitleCellObject

@property(nonatomic, weak) UIImage* imageFromCache;
@property(nonatomic, weak) id contact;

- (void)getImageCacheForCell: (ContactTableViewCell *)cell;

@end
