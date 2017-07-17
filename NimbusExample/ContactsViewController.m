
//
//  ContactsViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/20/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "ContactsViewController.h"
#import "ContactCellObject.h"
#import "ContactTableViewCell.h"
#import "NimbusModels.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "Constants.h"
#import "ContactCache.h"

@interface ContactsViewController () <NITableViewModelDelegate, UISearchResultsUpdating>

@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, strong) UISearchController* searchController;
@property (nonatomic, strong) ResultTableViewController* searchResultTableViewController;

@end

@implementation ContactsViewController

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ContactsViewController* sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ContactsViewController alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
    
        _contactQueue = dispatch_queue_create("SHOWER_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
   
    self.title = @"Contacts";
    [self setupTableMode];
    [self showContactBook];
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _contactBook = [ContactBook sharedInstance];
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
   
    [self.tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    self.tableView.dataSource = _model;
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
    _searchController.dimsBackgroundDuringPresentation = YES;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchController.searchBar;
}

#pragma mark - GetList Contact and add to models

- (void)getContactBook {
    
    dispatch_async(_contactQueue, ^ {
        
        int contacts = (int)_contactEntityList.count;
        NSString* groupNameContact = @"";

        // Run on background to get name group
        for (int i = 0; i < contacts; i++) {
            
            NSString* name = [_contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = [name substringToIndex:1];
            
            if ([groupNameContact.uppercaseString rangeOfString:firstChar.uppercaseString].location == NSNotFound) {
                
                groupNameContact = [groupNameContact stringByAppendingString:firstChar];
            }

        }
        
        int characterGroupNameCount = (int)[groupNameContact length];
        
        // Run on background to get object
        for (int i = 0; i < contacts; i++) {
            
            if (i < characterGroupNameCount) {
 
                [_model addSectionWithTitle:[groupNameContact substringWithRange:NSMakeRange(i,1)]];
            }
            
            ContactEntity* contactEntity = _contactEntityList[i];
            NSString* name = [_contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = [name substringToIndex:1];
        
            NSRange range = [groupNameContact rangeOfString:firstChar];
        
            if (range.location != NSNotFound) {
                
                ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                cellObject.contact = contactEntity;
                cellObject.contactTitle = contactEntity.name;
                [_model addObject:cellObject toSection:range.location];
            }
        }
        
        [_model updateSectionIndex];
        
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

        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
        _searchResultTableViewController.listContactBook = [_contactEntityList filteredArrayUsingPredicate:predicate];
        [_searchResultTableViewController viewWillAppear:true];
    }

}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    id object = [_model objectAtIndexPath:indexPath];
    ContactEntity* contactEntity = [(ContactCellObject *)object contact];
    NSLog(@"%@", contactEntity.name);
    
    [UIView animateWithDuration:0.2 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

#pragma mark - heigh for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    CGFloat height = tableView.rowHeight;
    id object = [_model objectAtIndexPath:indexPath];
    id class = [object cellClass];
    
    if ([class respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
        
        height = [class heightForObject:object atIndexPath:indexPath tableView:tableView];
    }
    
    return height;
}

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    ContactTableViewCell* contactTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
   
    if (contactTableViewCell.model != object) {
        
        ContactEntity* contactEntity = [object contact];
        ContactCellObject* cellObject = (ContactCellObject *)object;
        
        contactTableViewCell.identifier = contactEntity.identifier;
        contactTableViewCell.model = object;
        
        UIImage* image = cellObject.contactImage;
        
        if(image) {
            
            cellObject.contactImage = image;
        } else {
            
            cellObject.contactImage = contactEntity.profileImageDefault;
            [cellObject getImageCacheForCell:contactTableViewCell];
        }
        
        [contactTableViewCell shouldUpdateCellWithObject:object];
    
    }
  
    return contactTableViewCell;
}

@end

