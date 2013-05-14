//
//  DRRWhereTableViewController.m
//  Food?
//
//  Created by drocco on 5/13/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import "DRRWhereTableViewController.h"
#import <OAuthConsumer/OAuthConsumer.h>

@interface DRRWhereTableViewController ()

@property (strong, nonatomic) OAConsumer *consumer;
@property (strong, nonatomic) OAToken *token;

@property (strong, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *numberCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ratingCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *URLCell;

@end

@implementation DRRWhereTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //Don't get what goes here
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.consumer = [[OAConsumer alloc] initWithKey:@"a_UNc0Cz8ZzYfVMU5HbllQ" secret:@"923hvPmwxI4NNdX4PJZy7nfUlLU"];
    self.token = [[OAToken alloc] initWithKey:@"aJQMRewgVS8ifBqbzNZFgq2IY7G6aSXe" secret:@"S7s8UlDnA-QrfNgAM79OVuZP5tU"];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/business/%@", self.yelpID]];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:self.consumer token:self.token realm:nil signatureProvider:nil];

    [request prepare];

    NSError *err;
    NSURLResponse *resp;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];

    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];

    self.nameCell.detailTextLabel.text = response[@"name"];
    self.numberCell.detailTextLabel.text = response[@"display_phone"];
    self.locationCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", response[@"location"][@"display_address"][0]];
    self.ratingCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ stars",response[@"rating"]];
    self.URLCell.detailTextLabel.text = response[@"url"];

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
