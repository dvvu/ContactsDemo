//
//  Constants.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


#define iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version) [[[UIDevice currentDevice] systemVersion] floatValue] >= version

// 10M
#define MAX_CACHE_SIZE 34*1024*1024

#endif /* Constants_h */


#pragma mark - contacts Authorizatio Status
typedef enum {
    ContactAuthorizationStatusDenied = 1,
    ContactAuthorizationStatusRestricted = 2,
} ContactAuthorizationStatus;


#pragma mark - contacts loading Error
typedef enum {
    ContactLoadingFail = 3
} ErorrCode;

