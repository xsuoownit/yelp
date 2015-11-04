//
//  FiltersViewController.m
//  yelp
//
//  Created by Xin Suo on 11/3/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, assign) BOOL offerDeal;
@property (nonatomic, assign) NSNumber *distance;
@property (nonatomic, assign) NSNumber *sortMode;
@property (nonatomic, strong) NSMutableSet *selectedCategories;

- (void) initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.offerDeal = NO;
        self.distance = [NSNumber numberWithFloat:0.0];
        self.sortMode = [NSNumber numberWithInt:0];
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *navigationBarTintColor = [UIColor colorWithRed:191/255.0 green:25/255.0 blue:0 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:navigationBarTintColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.title = @"Filter";
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    [cancelButton.layer setMasksToBounds:YES];
    cancelButton.frame = CGRectMake(0.0, 100.0, 60.0, 28.0);
    [cancelButton addTarget:self action:@selector(onCancelTapped)  forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    [searchButton.layer setMasksToBounds:YES];
    searchButton.frame = CGRectMake(0.0, 100.0, 60.0, 28.0);
    [searchButton addTarget:self action:@selector(onSearchTapped)  forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories[section][@"value"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    cell.titleLabel.text = self.categories[indexPath.section][@"value"][indexPath.row][@"name"];
    switch (indexPath.section) {
        case 0:
            cell.on = self.offerDeal;
            break;
        case 1:
            cell.on = [self.categories[1][@"value"][indexPath.row][@"code"] isEqualToNumber:self.distance];
            break;
        case 2:
            cell.on = [self.categories[2][@"value"][indexPath.row][@"code"] isEqualToNumber:self.sortMode];
            break;
        case 3:
            cell.on = [self.selectedCategories containsObject:self.categories[3][@"value"][indexPath.row][@"code"]];
            break;
        default:
            break;
    }
    cell.delegate  = self;
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.categories[section][@"name"];
}

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    switch (indexPath.section) {
        case 0:
            if (value) {
                self.offerDeal = YES;
            } else {
                self.offerDeal = NO;
            }
            break;
        case 1:
            self.distance = self.categories[1][@"value"][indexPath.row][@"code"];
            break;
        case 2:
            self.sortMode = self.categories[2][@"value"][indexPath.row][@"code"];
            break;
        case 3:
            if (value) {
                [self.selectedCategories addObject:self.categories[3][@"value"][indexPath.row][@"code"]];
            } else {
                [self.selectedCategories removeObject:self.categories[3][@"value"][indexPath.row][@"code"]];
            }
        default:
            break;
    }
    [self.tableView reloadData];
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    [filters setObject:[NSNumber numberWithBool:self.offerDeal] forKey:@"deals"];
    
    [filters setObject:self.distance forKey:@"distance"];
    
    [filters setObject:self.sortMode forKey:@"sortMode"];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSString *category in self.selectedCategories) {
            [names addObject:category];
        }
        [filters setObject:names forKey:@"categories"];
    }
    
    return filters;
}

- (void)onCancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearchTapped {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCategories {
    
    self.categories = @[
                        @{@"name": @"Offering a Deal",
                          @"value": @[
                                  @{@"name": @"Offering a Deal", @"code": @"offeringadeal"}
                                  ]},
                        @{@"name": @"Distance",
                          @"value": @[
                                  @{@"name": @"Auto", @"code": [NSNumber numberWithFloat:0.0]},
                                  @{@"name": @"0.3 miles", @"code": [NSNumber numberWithFloat:0.3]},
                                  @{@"name": @"1 mile", @"code": [NSNumber numberWithFloat:1.0]},
                                  @{@"name": @"5 miles", @"code": [NSNumber numberWithFloat:5.0]},
                                  @{@"name": @"20 miles", @"code": [NSNumber numberWithFloat:20.0]}
                                  ]},
                        @{@"name": @"Sort By",
                          @"value": @[
                                  @{@"name": @"Best Match", @"code": [NSNumber numberWithInt:0]},
                                  @{@"name": @"Distance", @"code": [NSNumber numberWithInt:1]},
                                  @{@"name": @"Highest Rated", @"code": [NSNumber numberWithInt:2]}
                                  ]},
                        @{@"name": @"Category",
                          @"value": @[
                                  @{@"name": @"Afghan", @"code": @"afghani"},
                                  @{@"name": @"African", @"code": @"african"},
                                  @{@"name": @"American, New", @"code": @"newamerican"},
                                  @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                                  @{@"name": @"Arabian", @"code": @"arabian"},
                                  @{@"name": @"Argentine", @"code": @"argentine"},
                                  @{@"name": @"Armenian", @"code": @"armenian"},
                                  @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                                  @{@"name": @"Asturian", @"code": @"asturian"},
                                  @{@"name": @"Australian", @"code": @"australian"},
                                  @{@"name": @"Austrian", @"code": @"austrian"},
                                  @{@"name": @"Baguettes", @"code": @"baguettes"},
                                  @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                                  @{@"name": @"Barbeque", @"code": @"bbq"},
                                  @{@"name": @"Basque", @"code": @"basque"},
                                  @{@"name": @"Bavarian", @"code": @"bavarian"},
                                  @{@"name": @"Beer Garden", @"code": @"beergarden"},
                                  @{@"name": @"Beer Hall", @"code": @"beerhall"},
                                  @{@"name": @"Beisl", @"code": @"beisl"},
                                  @{@"name": @"Belgian", @"code": @"belgian"},
                                  @{@"name": @"Bistros", @"code": @"bistros"},
                                  @{@"name": @"Black Sea", @"code": @"blacksea"},
                                  @{@"name": @"Brasseries", @"code": @"brasseries"},
                                  @{@"name": @"Brazilian", @"code": @"brazilian"},
                                  @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                                  @{@"name": @"British", @"code": @"british"},
                                  @{@"name": @"Buffets", @"code": @"buffets"},
                                  @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                                  @{@"name": @"Burgers", @"code": @"burgers"},
                                  @{@"name": @"Burmese", @"code": @"burmese"},
                                  @{@"name": @"Cafes", @"code": @"cafes"},
                                  @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                                  @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                                  @{@"name": @"Cambodian", @"code": @"cambodian"},
                                  @{@"name": @"Canadian", @"code": @"New)"},
                                  @{@"name": @"Canteen", @"code": @"canteen"},
                                  @{@"name": @"Caribbean", @"code": @"caribbean"},
                                  @{@"name": @"Catalan", @"code": @"catalan"},
                                  @{@"name": @"Chech", @"code": @"chech"},
                                  @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                                  @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                                  @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                                  @{@"name": @"Chilean", @"code": @"chilean"},
                                  @{@"name": @"Chinese", @"code": @"chinese"},
                                  @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                                  @{@"name": @"Corsican", @"code": @"corsican"},
                                  @{@"name": @"Creperies", @"code": @"creperies"},
                                  @{@"name": @"Cuban", @"code": @"cuban"},
                                  @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                                  @{@"name": @"Cypriot", @"code": @"cypriot"},
                                  @{@"name": @"Czech", @"code": @"czech"},
                                  @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                                  @{@"name": @"Danish", @"code": @"danish"},
                                  @{@"name": @"Delis", @"code": @"delis"},
                                  @{@"name": @"Diners", @"code": @"diners"},
                                  @{@"name": @"Dumplings", @"code": @"dumplings"},
                                  @{@"name": @"Eastern European", @"code": @"eastern_european"},
                                  @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                                  @{@"name": @"Fast Food", @"code": @"hotdogs"},
                                  @{@"name": @"Filipino", @"code": @"filipino"},
                                  @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                                  @{@"name": @"Fondue", @"code": @"fondue"},
                                  @{@"name": @"Food Court", @"code": @"food_court"},
                                  @{@"name": @"Food Stands", @"code": @"foodstands"},
                                  @{@"name": @"French", @"code": @"french"},
                                  @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                                  @{@"name": @"Galician", @"code": @"galician"},
                                  @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                                  @{@"name": @"Georgian", @"code": @"georgian"},
                                  @{@"name": @"German", @"code": @"german"},
                                  @{@"name": @"Giblets", @"code": @"giblets"},
                                  @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                                  @{@"name": @"Greek", @"code": @"greek"},
                                  @{@"name": @"Halal", @"code": @"halal"},
                                  @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                                  @{@"name": @"Heuriger", @"code": @"heuriger"},
                                  @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                                  @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                                  @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                                  @{@"name": @"Hot Pot", @"code": @"hotpot"},
                                  @{@"name": @"Hungarian", @"code": @"hungarian"},
                                  @{@"name": @"Iberian", @"code": @"iberian"},
                                  @{@"name": @"Indian", @"code": @"indpak"},
                                  @{@"name": @"Indonesian", @"code": @"indonesian"},
                                  @{@"name": @"International", @"code": @"international"},
                                  @{@"name": @"Irish", @"code": @"irish"},
                                  @{@"name": @"Island Pub", @"code": @"island_pub"},
                                  @{@"name": @"Israeli", @"code": @"israeli"},
                                  @{@"name": @"Italian", @"code": @"italian"},
                                  @{@"name": @"Japanese", @"code": @"japanese"},
                                  @{@"name": @"Jewish", @"code": @"jewish"},
                                  @{@"name": @"Kebab", @"code": @"kebab"},
                                  @{@"name": @"Korean", @"code": @"korean"},
                                  @{@"name": @"Kosher", @"code": @"kosher"},
                                  @{@"name": @"Kurdish", @"code": @"kurdish"},
                                  @{@"name": @"Laos", @"code": @"laos"},
                                  @{@"name": @"Laotian", @"code": @"laotian"},
                                  @{@"name": @"Latin American", @"code": @"latin"},
                                  @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                                  @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                                  @{@"name": @"Malaysian", @"code": @"malaysian"},
                                  @{@"name": @"Meatballs", @"code": @"meatballs"},
                                  @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                                  @{@"name": @"Mexican", @"code": @"mexican"},
                                  @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                                  @{@"name": @"Milk Bars", @"code": @"milkbars"},
                                  @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                                  @{@"name": @"Modern European", @"code": @"modern_european"},
                                  @{@"name": @"Mongolian", @"code": @"mongolian"},
                                  @{@"name": @"Moroccan", @"code": @"moroccan"},
                                  @{@"name": @"New Zealand", @"code": @"newzealand"},
                                  @{@"name": @"Night Food", @"code": @"nightfood"},
                                  @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                                  @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                                  @{@"name": @"Oriental", @"code": @"oriental"},
                                  @{@"name": @"Pakistani", @"code": @"pakistani"},
                                  @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                                  @{@"name": @"Parma", @"code": @"parma"},
                                  @{@"name": @"Persian/Iranian", @"code": @"persian"},
                                  @{@"name": @"Peruvian", @"code": @"peruvian"},
                                  @{@"name": @"Pita", @"code": @"pita"},
                                  @{@"name": @"Pizza", @"code": @"pizza"},
                                  @{@"name": @"Polish", @"code": @"polish"},
                                  @{@"name": @"Portuguese", @"code": @"portuguese"},
                                  @{@"name": @"Potatoes", @"code": @"potatoes"},
                                  @{@"name": @"Poutineries", @"code": @"poutineries"},
                                  @{@"name": @"Pub Food", @"code": @"pubfood"},
                                  @{@"name": @"Rice", @"code": @"riceshop"},
                                  @{@"name": @"Romanian", @"code": @"romanian"},
                                  @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                                  @{@"name": @"Rumanian", @"code": @"rumanian"},
                                  @{@"name": @"Russian", @"code": @"russian"},
                                  @{@"name": @"Salad", @"code": @"salad"},
                                  @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                                  @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                                  @{@"name": @"Scottish", @"code": @"scottish"},
                                  @{@"name": @"Seafood", @"code": @"seafood"},
                                  @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                                  @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                                  @{@"name": @"Singaporean", @"code": @"singaporean"},
                                  @{@"name": @"Slovakian", @"code": @"slovakian"},
                                  @{@"name": @"Soul Food", @"code": @"soulfood"},
                                  @{@"name": @"Soup", @"code": @"soup"},
                                  @{@"name": @"Southern", @"code": @"southern"},
                                  @{@"name": @"Spanish", @"code": @"spanish"},
                                  @{@"name": @"Steakhouses", @"code": @"steak"},
                                  @{@"name": @"Sushi Bars", @"code": @"sushi"},
                                  @{@"name": @"Swabian", @"code": @"swabian"},
                                  @{@"name": @"Swedish", @"code": @"swedish"},
                                  @{@"name": @"Swiss Food", @"code": @"swissfood"},
                                  @{@"name": @"Tabernas", @"code": @"tabernas"},
                                  @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                                  @{@"name": @"Tapas Bars", @"code": @"tapas"},
                                  @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                                  @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                                  @{@"name": @"Thai", @"code": @"thai"},
                                  @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                                  @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                                  @{@"name": @"Trattorie", @"code": @"trattorie"},
                                  @{@"name": @"Turkish", @"code": @"turkish"},
                                  @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                                  @{@"name": @"Uzbek", @"code": @"uzbek"},
                                  @{@"name": @"Vegan", @"code": @"vegan"},
                                  @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                                  @{@"name": @"Venison", @"code": @"venison"},
                                  @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                                  @{@"name": @"Wok", @"code": @"wok"},
                                  @{@"name": @"Wraps", @"code": @"wraps"},
                                  @{@"name": @"Yugoslav", @"code": @"yugoslav"}
                                  ]}
                        ];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
