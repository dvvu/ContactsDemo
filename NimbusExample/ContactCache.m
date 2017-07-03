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
} ItemsWillDelete;

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
        
            // Add key into keyList
            [_keyList addObject:key];
            
            // Get size of image
            int pixelImage = [self imageSize:image];
            
            // Add size to check condition
            _contactCacheSize += pixelImage;
            
            NSLog(@"%u",_contactCacheSize/1024/1024);
            
            // size of image < valid memory?
            if (pixelImage < _maxCacheSize) {
                
//                int sizeDelete = _contactCacheSize - _maxCacheSize;
//                
//                if (sizeDelete > 0) {
//                    
//                    ItemsWillDelete itemsWillDelete = [self listItemWillDelete:sizeDelete];
//                    
//                    for (int i = 0; i < itemsWillDelete.numbuerItemDelete; i++) {
//                        
//                        [_contactCache removeObjectForKey:[_keyList objectAtIndex:i]];
//                    }
//                    _contactCacheSize -= itemsWillDelete.totalSize;
//                }
//          
//                [_contactCache setObject:[self makeRoundImage:image] forKey:key];
                [self writeToDirectory:[self makeRoundImage:image] forkey:key];
                
            } else if (pixelImage == _maxCacheSize) {
            
                [_contactCache removeAllObjects];
                [_contactCache setObject:[self makeRoundImage:image] forKey:key];
            }
        });
    }
}

#pragma mark - delete list item

- (ItemsWillDelete)listItemWillDelete:(NSUInteger)sizeDelete {
    
    int totalSize = 0;
    int numbuerItemDelete = 0;
    
    for (int i = 0; i < _keyList.count; i++) {
    
        if(totalSize < sizeDelete) {
            
            // Total + size of item at index
            totalSize += [self imageSize:[_contactCache objectForKey:[_keyList objectAtIndex:i]]];
            numbuerItemDelete ++;
            
        } else {
            
            break;
        }
    }
    
    ItemsWillDelete itemWillDelete;
    itemWillDelete.numbuerItemDelete = numbuerItemDelete;
    itemWillDelete.totalSize = totalSize;
    return itemWillDelete;
}

#pragma mark - get to cache

- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion {
    
    dispatch_async(_cacheImageQueue, ^ {
        
        if (key) {
            
            if (completion) {
                
                UIImage* image = [self getImageFromCache:key];
                
                if (image) {
                    
                    // Cache
                    completion(image);
                } else {
                    
                    // Disk
                    completion([self getImageFromDirectory: key]);
                }
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

#pragma mark - write image into cache

- (void)writeToCache:(UIImage *)image forkey:(NSString *)key {
    
    if (image && key) {
        [_contactCache setObject:image forKey:key];
    }
}

#pragma mark - write image into dir

- (void)writeToDirectory:(UIImage *)image forkey:(NSString *)key {
    
    if (image != nil) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:key];
        NSString* filePath = [path stringByAppendingPathComponent:@"image.png"];
       
        BOOL isDirectory;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            
            NSError* error = nil;
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
           
            if(error) {
               
                NSLog(@"folder creation failed. %@",[error localizedDescription]);
            } else {
                
//                NSData* imageData = UIImagePNGRepresentation(image);
                [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                
            }
            
        }

    }
}

#pragma mark - get image from cache

- (UIImage *)getImageFromCache:(NSString *)key {
    
    if (key) {
        
        return [_contactCache objectForKey:key];
    }
    
    return nil;
}

#pragma mark - get image from dir

- (UIImage *)getImageFromDirectory:(NSString *)key {
  
    if (key) {
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:key];
        NSString* filePath = [path stringByAppendingPathComponent:@"image.png"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
         
            UIImage* image = [UIImage imageWithContentsOfFile:filePath];
            return image;
        }
    }
    
    return nil;
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
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    UIImage* imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    // End
    UIGraphicsEndImageContext();
    
    return imageNew;
}

@end
