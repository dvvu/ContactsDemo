//
//  ContactsViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/20/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "ContactsViewController.h"
#import "NimbusModels.h"
#import "ContactCell.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "Constants.h"
#import "ContactCache.h"

@interface ContactsViewController () <NITableViewModelDelegate, UISearchBarDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (strong, nonatomic) UISearchController* searchController;
@property (nonatomic, strong) ResultTableViewController* searchResultTableViewController;

@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
     
        self.title = @"Contacts";
        _contactQueue = dispatch_queue_create("SHOW_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
        [self setupTableMode];
        [self showContactBook];
    }
    
    return self;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _contactBook = [ContactBook sharedInstance];
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
    self.tableView.dataSource = _model;
//    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self createSearchController];
    
}

#pragma mark - Show Contacts

- (void)showContactBook {
    
    [_contactBook getPermissionContacts:^(NSError* error) {
        
        if((error.code == ContactAuthorizationStatusDenied) || (error.code == ContactAuthorizationStatusRestricted)) {
           
            [[[UIAlertView alloc] initWithTitle:@"This app requires access to your contacts to function properly." message: @"Please! Go to setting!" delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"GO TO SETTING", nil] show];
        } else {
           
            [_contactBook getContacts:^(NSMutableArray* contactEntityList, NSError* error) {
                if(error.code == ContactLoadingFailError) {
                  
                    [[[UIAlertView alloc] initWithTitle:@"This Contact is empty." message: @"Please! Check your contacts and try again!" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles: nil, nil] show];
                } else {
                    
                    _contactEntityList = [NSArray arrayWithArray:contactEntityList];
                    [self getContactBook];
                }
            }];
        }
    }];
}

#pragma mark - Create searchBar

- (void)createSearchController {
    
    _searchResultTableViewController = [[ResultTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultTableViewController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = YES;
    _searchController.searchBar.delegate = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchController.searchBar;
    
}

#pragma mark - GetList Contact and add to models

- (void)getContactBook {
    
    NSMutableArray* groupNameContact = [[NSMutableArray alloc] init];
   
    dispatch_async(_contactQueue, ^ {
        
         // Run on background to get GroupName
        for (ContactEntity* contactEntity in _contactEntityList) {
            
            BOOL isExisted = false;
            
            // Replace deleted @" " in string
            NSString* name = [contactEntity.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* firstChar = [name substringToIndex:1];
        
            if (groupNameContact.count > 0) {
            
                for (int i = 0; i < groupNameContact.count; i++) {
                    
                    if([firstChar isEqualToString:groupNameContact[i]]) {
               
                        isExisted = true;
                    }
                }
                
                if (!isExisted) {
                 
                    [groupNameContact addObject:firstChar];
                }
                
            } else {
              
                [groupNameContact addObject:firstChar];
            }
        }
        
         // Run on background to get object
        for (int i = 0; i < groupNameContact.count; i++) {
            
            [_model addSectionWithTitle:groupNameContact[i]];
            NSMutableArray* objects = [NSMutableArray array];
            for (ContactEntity* contactEntity in _contactEntityList) {
                
                NSString* name = [contactEntity.name stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString* firstChar = [name substringToIndex:1];
                
                if ([firstChar isEqualToString:groupNameContact[i]]) {
                  
                    ContactCell* cellObject = [ContactCell objectWithTitle:contactEntity.name image:[contactEntity profileImageDefault]];
                   
                    [[ContactCache sharedInstance] getImageForKey:contactEntity.identifier completionWith:^(UIImage *image) {
                       
                        if (image) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                cellObject.image = image;
                                [self.tableView beginUpdates];
                                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects: [_model indexPathForObject:cellObject], nil] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                            });
                        }
                    }];
                    
                    cellObject.contact = contactEntity;
                    [objects addObject:cellObject];
                }
                
            }
            
            [_model addObjectsFromArray:objects];
            [_model updateSectionIndex];
        }
        
        // Run on main Thread
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [self.tableView reloadData];
        });
    });
}

#pragma mark - updateSearchResultViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString* searchString = searchController.searchBar.text;
    if (searchString.length > 0) {
        
        // Search by string
        _searchResultTableViewController.tableView.contentInset = UIEdgeInsetsMake(self.tableView.tableHeaderView.frame.size.height+20, 0, 0, 0);
        _searchResultTableViewController.listContactBook = [NSArray arrayWithArray:[self searchResult:searchString]];
        [_searchResultTableViewController viewDidLoad];
    }

}

#pragma mark - getResultSearch

- (NSMutableArray *)searchResult: (NSString *) searchString {
    
    NSMutableArray<ContactEntity*> *result = [[NSMutableArray alloc]init];
    for (ContactEntity* contactEntity in _contactEntityList) {
        
        if ([contactEntity.name.uppercaseString rangeOfString:searchString.uppercaseString].location != NSNotFound) {
            
            [result addObject:contactEntity];
        }
    }
    return result;
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    id object = [_model objectAtIndexPath:indexPath];
    ContactEntity* contactEntity = [(ContactCell*)object contact];
    NSLog(@"%@",  contactEntity.phone);
}

#pragma mark - Nimbus delegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    UITableViewCell* cell = [NICellFactory tableViewModel:tableViewModel cellForTableView:tableView atIndexPath:indexPath withObject:object];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

@end

