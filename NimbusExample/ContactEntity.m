//
//  ContactEntity.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactEntity.h"
#import "Constants.h"
#import "ContactCache.h"

@implementation ContactEntity

@synthesize name;
@synthesize phone;
@synthesize identifier;

#pragma mark - getCNContact

- (UIImage *)profileImageWithData:(NSData *)data {
    
    UIImage* profileImage;
    
    if(data) {

        profileImage = [UIImage imageWithData:data];
    }
    return profileImage;
}

- (ContactEntity *)initWithCNContacts:(CNContact *)contact {
    
    self = [super init];
    if (self) {
        
        // Get Name
        NSString* firstName = @"";
        NSString* lastName = @"";
        
        if (contact.givenName) {
          
            firstName = contact.givenName;
        }
        
        if (contact.familyName) {
     
            lastName = contact.familyName;
        }
        
        self.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get ID Contact
        self.identifier = contact.identifier;
        // Get PhoneNumber
        self.phone = [[NSMutableArray alloc] init];
        
        for (CNLabeledValue* cNLabeledValue in contact.phoneNumbers) {
            
            NSString* phoneNumber = [cNLabeledValue.value stringValue];
            
            if([self validatePhone:phoneNumber]) {
        
                NSString* phoneNumberFormatted = [phoneNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
                [self.phone addObject:phoneNumberFormatted];
            }
            
        }
        
        // Get image-> need device
//        if (contact.imageData) {
//            UIImage* image = [[UIImage alloc]initWithData:contact.imageData];
//            
//            // Cache image for key->idContact. circle for image
//            [[ContactCache sharedInstance] setImageForKey:[self makeRoundImage:image] forKey: contact.identifier];
//        }
//        [[ContactCache sharedInstance] setImageForKey:[self makeRoundImage:[UIImage imageNamed:@"c"]] forKey: contact.identifier];
    }
    
    return self;
}

#pragma mark - getCNABRecordRef

- (ContactEntity *)initWithAddressBook:(ABRecordRef)contact {
   
    self = [super init];
    if (self) {
        // Get Name
        NSString* firstName = CFBridgingRelease(ABRecordCopyValue(contact, kABPersonFirstNameProperty));
        NSString* lastName = CFBridgingRelease(ABRecordCopyValue(contact, kABPersonLastNameProperty));
        
        if (!firstName) {
         
            firstName = @"";
        }
        
        if (!lastName) {
          
            lastName = @"";
        }
        
        self.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get ID Record
        NSString *recordId = [NSString stringWithFormat:@"%d",(ABRecordGetRecordID(contact))];
        self.identifier = recordId;
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        
        self.phone = [[NSMutableArray alloc] init];
        
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            
            NSString* phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            
            if ([self validatePhone:phoneNumber]) {
             
                NSString* phoneNumberFormatted = [phoneNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
                [self.phone addObject:phoneNumberFormatted];
            }
        }
        // Get image-> need to fix
//        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(contact);
//        
//        if (imgData) {
//         
//            UIImage  *image = [UIImage imageWithData:imgData];
//            [[ContactCache sharedInstance] setImageForKey:[self makeRoundImage:image] forKey: recordId];
//        }
        
//        [[ContactCache sharedInstance] setImageForKey:[self makeRoundImage:[UIImage imageNamed:@"t"]] forKey: recordId];
    }
    
    return self;
}

#pragma mark - validate phoneNumber

- (BOOL)validatePhone:(NSString *)phoneNumber {
    
    NSString* phoneRegex = @"^[0-9-\\s]{6,14}$";
    NSPredicate* validatePhoneNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [validatePhoneNumber evaluateWithObject:phoneNumber];
}

#pragma mark - draw image circle

- (UIImage *)makeRoundImage:(UIImage *)image {
    
    //resize image
    CGRect rect;
    
    if( image.size.width > image.size.height) {
        
        rect = CGRectMake(0,0,image.size.height,image.size.height);
    } else {
        
        rect = CGRectMake(0,0,image.size.width,image.size.width);
    }
    
    // Begin a new image that will be the new image with the rounded corners
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    UIGraphicsBeginImageContext(rect.size);
    
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:image.size.width/2] addClip];
    [image drawInRect:rect];
    
    // Get the imageV,
    UIImage* imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData* imageData = UIImagePNGRepresentation(imageNew);
    
    image = [UIImage imageWithData:imageData];
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
