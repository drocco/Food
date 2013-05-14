//
//  DRRWherePickerTableViewController.m
//  Food?
//
//  Created by drocco on 5/13/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import "DRRWherePickerTableViewController.h"
#import <OAuthConsumer/OAuthConsumer.h>

@interface DRRWherePickerTableViewController ()

@property (strong, atomic) NSArray *places;

@property (strong, nonatomic) OAConsumer *consumer;
@property (strong, nonatomic) OAToken *token;
@property (strong, nonatomic) CLLocationManager *lm;
@property (strong, atomic) CLLocation *loc;

- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end

@implementation DRRWherePickerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lm = [[CLLocationManager alloc] init];
    self.lm.delegate = self;
    self.lm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.lm.distanceFilter = 1000.0f;
    [self.lm startUpdatingLocation];
    
    self.consumer = [[OAConsumer alloc] initWithKey:@"a_UNc0Cz8ZzYfVMU5HbllQ" secret:@"923hvPmwxI4NNdX4PJZy7nfUlLU"];
    self.token = [[OAToken alloc] initWithKey:@"aJQMRewgVS8ifBqbzNZFgq2IY7G6aSXe" secret:@"S7s8UlDnA-QrfNgAM79OVuZP5tU"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.lm stopUpdatingLocation];
    self.loc = [locations lastObject];
}

- (IBAction)donePressed:(id)sender {
    NSIndexPath *index = self.tableView.indexPathForSelectedRow;
    
    self.parent.updatedEvent[@"pid"] = [self.places[index.row] objectForKey:@"id"];
    self.parent.updatedEvent[@"place"] = [self.places[index.row] objectForKey:@"name"];
    self.parent.whereText.text = [self.places[index.row] objectForKey:@"name"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f", searchBar.text, self.loc.coordinate.latitude, self.loc.coordinate.longitude]];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:self.consumer token:self.token realm:nil signatureProvider:nil];
    
    [request prepare];
    
    NSError *err;
    NSURLResponse *resp;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    self.places = response[@"businesses"];
    
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.places.count ?: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.places[indexPath.row] objectForKey:@"name"];
    
    float dist = [[self.places[indexPath.row] objectForKey:@"distance"] floatValue] * 0.000621371;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f miles", dist];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
