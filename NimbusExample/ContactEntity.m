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
    }
    
    return self;
}

#pragma mark - validate phoneNumber

- (BOOL)validatePhone:(NSString *)phoneNumber {
    
    NSString* phoneRegex = @"^[0-9-\\s]{6,14}$";
    NSPredicate* validatePhoneNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [validatePhoneNumber evaluateWithObject:phoneNumber];
}



@end
