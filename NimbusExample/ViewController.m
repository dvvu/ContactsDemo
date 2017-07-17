//
//  ViewController.m
//  NimbusExample
//
//  Created by Lee Hoa on 6/15/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ViewController.h"
#import "ContactsViewController.h"
#import "FriendsTableViewController.h"

@interface ViewController()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIButton* contactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    contactButton.frame = CGRectMake(20, self.view.frame.size.height/2, 100, 25);
    [contactButton setTitle:@"Contacts" forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(gotoContactsTableViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactButton];
    
    UIButton* friendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    friendButton.frame = CGRectMake(160, self.view.frame.size.height/2, 100, 25);
    [friendButton setTitle:@"Friends" forState:UIControlStateNormal];
    [friendButton addTarget:self action:@selector(gotoFriendsableViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:friendButton];
}

- (IBAction)gotoContactsTableViewController:(id)sender {
    
    ContactsViewController* contactsViewController = [ContactsViewController sharedInstance];
    [self.navigationController pushViewController:contactsViewController animated:YES];
}


- (IBAction)gotoFriendsableViewController:(id)sender {
    
    FriendsTableViewController* friendsViewController = [[FriendsTableViewController alloc] init];
    [self.navigationController pushViewController:friendsViewController animated:YES];
}

@end


