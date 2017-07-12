//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "NICellCatalog.h"
#import "ContactTableViewCell.h"

@protocol ContactCellObjectDelegate <NSObject>

- (BOOL)checkCellIsVisiable: (ContactTableViewCell *)cell;

@end

@interface ContactCellObject : NITitleCellObject

@property(nonatomic, weak) id<ContactCellObjectDelegate> delegate;

@property(nonatomic, weak) id contact;

@property(nonatomic, weak) UIImage* imageFromCache;

- (void)getImageCacheForCell: (ContactTableViewCell *)cell;

@end
