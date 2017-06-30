//
//  ContactEntity.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABAddressBook.h>
#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>

@interface ContactEntity : NSObject

@property (nonatomic, strong) NSMutableArray<NSString*>* phone;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSString* name;

#pragma mark - get image
- (UIImage*)profileImageWithData:(NSData* )data;

#pragma mark - intit CNContact
- (ContactEntity *)initWithCNContacts:(CNContact* )contact;

#pragma mark - get ABAddressBookRef
- (ContactEntity *)initWithAddressBook:(ABRecordRef)contact;

@end
