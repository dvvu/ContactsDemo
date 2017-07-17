//
//  ResultTableViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/26/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "NimbusModels.h"
#import "ContactCellObject.h"
#import "ContactTableViewCell.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "ContactEntity.h"
#import "ContactCache.h"

@interface ResultTableViewController () <NITableViewModelDelegate>

@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (nonatomic, strong ) NITableViewModel* model;

@end

@implementation ResultTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    // Dimiss keyboard when drag
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:true];
    [self setupTableView];
}

#pragma mark - setupView

- (void)setupTableView {
    
    dispatch_async(_resultSearchContactQueue, ^ {
        
        if(_listContactBook) {
            
            NSMutableArray* objects = [NSMutableArray array];
            
            for (ContactEntity* contactEntity in _listContactBook) {
                
                ContactCellObject* cellObject = [ContactCellObject objectWithTitle:contactEntity.name image:[contactEntity profileImageDefault]];
                cellObject.contact = contactEntity;
                cellObject.contactTitle = contactEntity.name;
                [objects addObject:(id<ContactModelProtocol>)cellObject];
            }
            
            _model = [[NITableViewModel alloc] initWithListArray:objects delegate:self];
            self.tableView.dataSource = _model;
            
            dispatch_async(dispatch_get_main_queue(), ^ {
            
                [self.tableView reloadData];
            });
        }
    });
    
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [_model objectAtIndexPath:indexPath];
    ContactEntity* contactEntity = [(ContactCellObject *)object contact];
    NSLog(@"%@",  contactEntity.phone);
    
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
