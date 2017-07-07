//
//  ResultTableViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/26/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "ContactTableViewCell.h"
#import "NimbusModels.h"
#import "ContactCellObject.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "ContactEntity.h"
#import "ContactCache.h"

@interface ResultTableViewController ()

@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (strong, nonatomic) NITableViewModel* model;
@property (nonatomic, strong) NICellFactory* cellFactory;
@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    _cellFactory = [[NICellFactory alloc] init];
    [_cellFactory mapObjectClass:[ContactCellObject class] toCellClass:[ContactTableViewCell class]];
    
    // Dimis keyboard when scroll
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setupTableView];
}

- (void)setupTableView {
    
    dispatch_async(_resultSearchContactQueue, ^ {
        
        NSMutableArray* objects = [NSMutableArray array];
        
        for (ContactEntity* contactEntity in _listContactBook) {

            ContactCellObject* cellObject = [ContactCellObject objectWithTitle:contactEntity.name image:[contactEntity profileImageDefault]];
            cellObject.contact = contactEntity;
            [objects addObject:cellObject];
        }
        
        _model = [[NITableViewModel alloc] initWithListArray:objects delegate:_cellFactory];
        self.tableView.dataSource = _model;
    
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [self.tableView reloadData];
        });
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

@end
