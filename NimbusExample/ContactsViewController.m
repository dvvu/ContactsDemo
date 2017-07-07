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

@interface ContactsViewController () <UITableViewDelegate ,UISearchBarDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (strong, nonatomic) UISearchController* searchController;
@property (nonatomic, strong) ResultTableViewController* searchResultTableViewController;
@property (nonatomic, strong) NICellFactory* cellFactory;

@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
   
        self.title = @"Contacts";
        _contactQueue = dispatch_queue_create("SHOWER_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
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
    
    _cellFactory = [[NICellFactory alloc] init];
    [_cellFactory mapObjectClass:[ContactCellObject class] toCellClass:[ContactTableViewCell class]];
    
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:_cellFactory];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
  
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
    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = YES;
    _searchController.searchBar.delegate = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchController.searchBar;
}

#pragma mark - GetList Contact and add to models

- (void)getContactBook {
    
    dispatch_async(_contactQueue, ^ {
        
        int contacts = _contactEntityList.count;
        NSString* groupNameContact = @"";

        for (int i = 0; i < contacts; i++) {
            
            NSString* name = [_contactEntityList[i].name stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* firstChar = [name substringToIndex:1];
            
            if ([groupNameContact.uppercaseString rangeOfString:firstChar.uppercaseString].location == NSNotFound) {
                
                groupNameContact = [groupNameContact stringByAppendingString:firstChar];
            }

        }
        
        NSUInteger characterGroupNameContactCount = [groupNameContact length];
        
        // Run on background to get object
        for (int i = 0; i < contacts; i++) {
            
            if (i < characterGroupNameContactCount) {
 
                [_model addSectionWithTitle:[groupNameContact substringWithRange:NSMakeRange(i,1)]];
            }
            
            ContactEntity* contactEntity = _contactEntityList[i];
            NSString* name = [contactEntity.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* firstChar = [name substringToIndex:1];
        
            NSRange range = [groupNameContact rangeOfString:firstChar];
        
            if (range.location != NSNotFound) {
                
                ContactCellObject* cellObject = [ContactCellObject objectWithTitle:contactEntity.name image:[contactEntity profileImageDefault]];
                cellObject.contact = contactEntity;
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
        
        // Search by string
        _searchResultTableViewController.listContactBook = [NSArray arrayWithArray:[self searchResult:searchString]];
        [_searchResultTableViewController viewWillAppear:true];
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
    ContactEntity* contactEntity = [(ContactCellObject *)object contact];
    NSLog(@"%@", contactEntity.name);
    
    [UIView animateWithDuration:0.2 animations: ^ {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

@end

