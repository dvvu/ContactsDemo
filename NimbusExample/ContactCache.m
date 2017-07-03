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
            NSLog(@"%u",_contactCacheSize/1024/1024);
            
            if (pixelImage < _maxCacheSize) {
                
                int sizeDelete = _contactCacheSize - _maxCacheSize;
                
                if(sizeDelete > 0) {
                    
                    ItemWillDeleteInfo itemWillDeleteInfo = [self listItemWillDelete:sizeDelete];
                    
                    for (int i = 0; i < itemWillDeleteInfo.numbuerItemDelete; i++) {
                        
                        [_contactCache removeObjectForKey:[_keyList objectAtIndex:i]];
                    }
                    _contactCacheSize -= itemWillDeleteInfo.totalSize;
                }
          
                [_contactCache setObject:[self makeRoundImage:image] forKey:key];

                
            } else if (pixelImage == _maxCacheSize) {
            
                [_contactCache removeAllObjects];
                [_contactCache setObject:[self makeRoundImage:image] forKey:key];
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
    
    dispatch_async(_cacheImageQueue, ^ {
        
        if(key) {
            
            if (completion) {
                
                UIImage* image = [_contactCache objectForKey:key];
                completion(image);
            }
        } else {
            
            if (completion) {
                
                completion(nil);
            }
        }
    });
}

- (NSUInteger)imageSize:(UIImage*)image {
    return [UIImageJPEGRepresentation(image, 1.0) length];
}


#pragma mark - draw image circle

- (UIImage *)makeRoundImage:(UIImage *)image {
    
    //resize image
    CGRect rect;
    int imageWidth = image.size.width;
    int imageHeight =  image.size.height;
    
    if (imageWidth > imageHeight) {
        
        rect = CGRectMake(0,0,imageHeight,imageHeight);
    } else {
        
        rect = CGRectMake(0,0,imageWidth,imageWidth);
    }
    // Begin a new image that will be the new image with the rounded corners
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    // Add a clip before drawing anything, in the shape of an rounded rect
    UIGraphicsBeginImageContext(rect.size);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    
    UIImage* imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    UIGraphicsEndImageContext();
    
    return imageNew;
}
@end
