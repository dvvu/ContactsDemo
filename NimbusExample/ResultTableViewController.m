//
//  ResultTableViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/26/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "NimbusModels.h"
#import "ContactCell.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "ContactEntity.h"
#import "ContactCache.h"

@interface ResultTableViewController () <NITableViewModelDelegate>

@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (strong, nonatomic) NITableViewModel* models;

@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    [self setupTableView];
}

- (void)setupTableView {
    
    dispatch_async(_resultSearchContactQueue, ^ {
        
        NSMutableArray* objects = [NSMutableArray array];
        
        for (ContactEntity* contactEntity in _listContactBook) {

            ContactCell* cellObject = [ContactCell objectWithTitle:contactEntity.name image:[UIImage imageNamed:@""]];
            [[ContactCache sharedInstance] getImageForKey:contactEntity.identifier completionWith:^(UIImage *image) {
                if (image) {
                    
                    cellObject.image = image;
                }
            }];
            
            cellObject.contact = contactEntity;
            [objects addObject:cellObject];
        }
        
        _models = [[NITableViewModel alloc] initWithListArray:objects delegate:self];
        self.tableView.dataSource = _models;
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [self.tableView reloadData];
        });
    });
    
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [_models objectAtIndexPath:indexPath];
    ContactEntity* contactEntity = [(ContactCell*) object contact];
    NSLog(@"%@",  contactEntity.phone);
}

#pragma mark - Nimbus delegate

- (UITableViewCell*)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    UITableViewCell* cell = [NICellFactory tableViewModel:tableViewModel cellForTableView:tableView atIndexPath:indexPath withObject:object];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

@end
