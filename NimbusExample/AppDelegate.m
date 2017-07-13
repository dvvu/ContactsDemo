//
//  AppDelegate.m
//  NimbusExample
//
//  Created by Lee Hoa on 6/15/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "AppDelegate.h"
#import "ContactsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
 
    ContactsViewController* contactsViewController = [[ContactsViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:contactsViewController];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
