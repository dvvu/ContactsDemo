//
//  ContactCache.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/29/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactCache : NSObject

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - cache image for key
- (void)setImageForKey:(UIImage *)image forKey:(NSString *)key;

#pragma mark - get image Cache
- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion;

@end
