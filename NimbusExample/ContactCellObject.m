//
//  ContactCellObject.m
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactCellObject.h"
#import "ContactEntity.h"
#import "ContactCache.h"

@implementation ContactCellObject

- (Class)cellClass {
    
    return [ContactTableViewCell class];
}

- (void)getImageCacheForCell: (ContactTableViewCell *)cell {
    
    __weak ContactTableViewCell* contactTableViewCell = cell;
    
    ContactEntity* contactEntity = _contact;
    
    [[ContactCache sharedInstance] getImageForKey:contactEntity.identifier completionWith:^(UIImage* image) {
        
        if (image) {
            
            _imageFromCache = image;
            
            if ([contactEntity.identifier isEqualToString:contactTableViewCell.identifier]) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    contactTableViewCell.profileImageView.image = image;
                });
            }
        }
    }];
}

@end
