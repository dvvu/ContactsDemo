//
//  ContactCache.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/29/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactCache.h"
#import "Constants.h"

@interface ContactCache()

@property (nonatomic, strong) NSCache *contactCache;
@property (nonatomic) NSUInteger contactCacheSize;
@property (nonatomic, strong) NSMutableArray<NSString*> *keyList;
@property (nonatomic) NSUInteger maxCacheSize;
@property (nonatomic) dispatch_queue_t cacheImageQueue;

@end

@implementation ContactCache

#pragma mark - Object info to delete

typedef struct {
    int totalSize;
    int numbuerItemDelete;
} ItemWillDeleteInfo;

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ContactCache *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ContactCache alloc] init];
    });
    return sharedInstance;
}

#pragma mark - intit

- (instancetype)init {

    self = [super init];
    if (self) {
        _maxCacheSize = MAX_CACHE_SIZE;
        _keyList = [[NSMutableArray alloc]init];
        _contactCache = [[NSCache alloc] init];
        _cacheImageQueue = dispatch_queue_create("CACHE_IMAGE_QUEUE", DISPATCH_QUEUE_SERIAL);
        [_contactCache setName:@"ContactImage"];
    }
    return self;
}

#pragma mark - save to cache with image

- (void)setImageForKey:(UIImage *)image forKey:(NSString *)key {
    
    if (image && key) {
        
        dispatch_async(_cacheImageQueue, ^ {
        
            [_keyList addObject:key];
            int pixelImage = [self imageSize:image];
            _contactCacheSize += pixelImage;
            NSLog(@"%d",_contactCacheSize);
            
            if (pixelImage < _maxCacheSize) {
                
                if(_contactCacheSize > _maxCacheSize) {
                    
                    ItemWillDeleteInfo itemWillDeleteInfo = [self listItemWillDelete:(_contactCacheSize - _maxCacheSize)];
                    
                    for (int i = 0; i < itemWillDeleteInfo.numbuerItemDelete; i++) {
                        
                        [_contactCache removeObjectForKey:[_keyList objectAtIndex:i]];
                    }
                    _contactCacheSize -= itemWillDeleteInfo.totalSize;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                
                    [_contactCache setObject:image forKey:key];
                });
                
            } else if (pixelImage == _maxCacheSize) {
            
                [_contactCache removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^ {
                
                    [_contactCache setObject:image forKey:key];
                });
            }
        });
    }
    
}

#pragma mark - delete list item

- (ItemWillDeleteInfo)listItemWillDelete:(NSUInteger)sizeDelete {
    
    int totalSize = 0;
    int numbuerItemDelete = 0;
    
    for (int i = 0; i < _keyList.count; i++) {
    
        if(totalSize < sizeDelete) {
            
            // Total + size of item at index
            totalSize += [self imageSize:[self getImageForKey:[_keyList objectAtIndex:i]]];
            numbuerItemDelete ++;
            
        } else {
            
            break;
        }
    }
    
    ItemWillDeleteInfo itemWillDeleteInfo;
    itemWillDeleteInfo.numbuerItemDelete = numbuerItemDelete;
    itemWillDeleteInfo.totalSize = totalSize;
    return itemWillDeleteInfo;
}

#pragma mark - get to cache with

- (UIImage*)getImageForKey:(NSString *)key {
  
    if(key) {
        
        return [_contactCache objectForKey:key];
    } else {
        
        return nil;
    }
}

- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion {
  
    if(key) {
        
        if (completion) {
    
            completion([_contactCache objectForKey:key]);
        }
    } else {
        
        if (completion) {
            
            completion(nil);
        }
    }
}

- (NSUInteger)imageSize:(UIImage*)image {
   
    NSData *imageData = UIImageJPEGRepresentation(image, 1); //1 it represents the quality of the image.
    return [imageData length];
}

@end
