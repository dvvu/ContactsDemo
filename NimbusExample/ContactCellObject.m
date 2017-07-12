//
//  ContactCellObject.m
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactCellObject.h"
#import "ContactCache.h"
#import "ContactEntity.h"

@implementation ContactCellObject

- (void)getImageCacheForCell: (ContactTableViewCell *)cell {
    
    __weak ContactTableViewCell* weakCell =  cell;
    
    ContactEntity* contactEntity = _contact;
    
    [[ContactCache sharedInstance] getImageForKey:contactEntity.identifier completionWith:^(UIImage* image) {
        
        if (image) {
            
            _imageFromCache = image;
            
            if ([contactEntity.identifier isEqualToString:weakCell.identifier]) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    weakCell.profileImageView.image = image;
                });
            }
        }
    }];
}

@end
