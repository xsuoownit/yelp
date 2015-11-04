//
//  MainViewController.m
//  yelp
//
//  Created by Xin Suo on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "BusinessCell.h"
#import "YelpClient.h"
#import "FiltersViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *businesses;

@end

@implementation MainViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [YelpBusiness searchWithTerm:@"Restaurants"
                            sortMode:YelpSortModeBestMatched
                          categories:nil
                               deals:NO
                              radius:nil
                          completion:^(NSArray *businesses, NSError *error) {
                              self.businesses = businesses;
                              [self.tableView reloadData];
                          }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.estimatedRowHeight = 140;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UIColor *navigationBarTintColor = [UIColor colorWithRed:191/255.0 green:25/255.0 blue:0 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:navigationBarTintColor];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Restaurants";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Filter" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:0.8f];
    [button.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    button.frame = CGRectMake(0.0, 100.0, 60.0, 28.0);
    [button addTarget:self action:@selector(onFilterTapped)  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)onFilterTapped {
    FiltersViewController *fvc = [[FiltersViewController alloc] init];
    fvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [YelpBusiness searchWithTerm:searchBar.text
                      completion:^(NSArray *businesses, NSError *error) {
                          self.businesses = businesses;
                          [self.tableView reloadData];
                      }];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)hideKeyboard {
    [self.searchBar resignFirstResponder];
}

- (void) filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    NSArray *categories = [filters objectForKey:@"categories"];
    
    YelpSortMode sortMode;
    if ([[filters objectForKey:@"sortMode"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        sortMode = YelpSortModeBestMatched;
    } else if ([[filters objectForKey:@"sortMode"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
        sortMode = YelpSortModeDistance;
    } else {
        sortMode = YelpSortModeHighestRated;
    }
    
    NSNumber *radius = [filters objectForKey:@"distance"];
    if ([radius isEqualToNumber:[NSNumber numberWithFloat:0.0]]) {
        radius = nil;
    }
    
    [YelpBusiness searchWithTerm:@"Restaurants"
                        sortMode:sortMode
                      categories:categories
                           deals:[[filters objectForKey:@"deals"] boolValue]
                          radius:radius
                      completion:^(NSArray *businesses, NSError *error) {
                          self.businesses = businesses;
                          [self.tableView reloadData];
                      }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end