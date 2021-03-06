//
//  FriendsTableViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 7/15/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "ContactCellObject.h"
#import "ContactTableViewCell.h"
#import "NimbusModels.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "ContactEntity.h"
#import "Constants.h"

@interface FriendsTableViewController ()

@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, strong) UISearchController* searchController;

@end

@implementation FriendsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        
        self.title = @"Friend";
        _contactQueue = dispatch_queue_create("SHOWER_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
        [self setupTableMode];
        [self showContactBook];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStylePlain target:self action:@selector(backtoViewController)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (IBAction)backtoViewController {
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _contactBook = [ContactBook sharedInstance];
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
    
    self.tableView.dataSource = _model;
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
                    _contactEntityList = nil;
                    _contactEntityList = [NSArray arrayWithArray:contactEntityList];
                    [self getContactBook];
                }
            }];
        }
    }];
}

#pragma mark - GetList Contact and add to models

- (void)getContactBook {
    
    dispatch_async(_contactQueue, ^ {
        
        int contacts = (int)_contactEntityList.count;
        NSString* groupNameContact = @"";
        
        // Run on background to get name group
        for (int i = 0; i < contacts; i++) {
            
            NSString* name = [_contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//[_contactEntityList[i].name stringByReplacingOccurrencesOfString:@" " withString:@""];
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
            NSString* name = [_contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//[contactEntity.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* firstChar = [name substringToIndex:1];
            
            NSRange range = [groupNameContact rangeOfString:firstChar];
            
            if (range.location != NSNotFound) {
                
                ContactCellObject* cellObject = [ContactCellObject objectWithTitle:contactEntity.name image:[contactEntity profileImageDefault]];
                cellObject.contact = contactEntity;
                
//                MBContactModel *model = [[MBContactModel alloc] init];
//                model.contactTitle = text;
                
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

@end
