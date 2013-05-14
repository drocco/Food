//
//  DRRDetailsTableViewController.m
//  Food?
//
//  Created by drocco on 5/10/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import "DRRDetailsTableViewController.h"
#import "DRRAppDelegate.h"
#import "DRRGuestTableViewController.h"
#import "DRRWhereTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DRRDetailsTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *event;
@property (weak, atomic) DRRAppDelegate *appDelegate;
@property (atomic) BOOL refreshInProgress;
@property (strong, nonatomic) NSDateFormatter *dfMySQL;
@property (strong, nonatomic) NSDateFormatter *dfUI;

-(void)refresh;
-(void)endFreshOnMain;
-(void)refreshData;
-(IBAction)acceptInvite:(id)sender;

@end

@implementation DRRDetailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)refresh {
    self.refreshInProgress = YES;
    if (![self.refreshControl isRefreshing]) {
        [self.refreshControl beginRefreshing];
        if (self.tableView.contentOffset.y == 0) {
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                
                self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
                
            } completion:^(BOOL finished){
                
            }];
            
        }
    }
    
    if (![FBSession activeSession] || ![[FBSession activeSession] isOpen]) {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self refresh];
        }];
    } else if (![self.appDelegate userID]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
            self.appDelegate.userID = result.id;
            [self refresh];
        }];
    } else {
        [self performSelectorInBackground:@selector(refreshData) withObject:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (DRRAppDelegate *)([[UIApplication sharedApplication] delegate]);
    self.refreshInProgress = NO;
    self.dfMySQL = [[NSDateFormatter alloc] init];
    [self.dfMySQL setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [self.dfMySQL setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.dfUI = [[NSDateFormatter alloc] init];
    [self.dfUI setDateStyle:NSDateFormatterShortStyle];
    [self.dfUI setTimeStyle:NSDateFormatterShortStyle];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
    
    if (self.isOwner) {
        self.navigationItem.rightBarButtonItem.title = @"Edit";
    }
    
    if (self.wasInvited) {
        self.navigationItem.rightBarButtonItem.title = @"Accept";
    }
    
    [self.whereCell setUserInteractionEnabled:NO];
    self.whereCell.accessoryType = UITableViewCellAccessoryNone;
    
    [self.whoCell setUserInteractionEnabled:NO];
    self.whoCell.accessoryType = UITableViewCellAccessoryNone;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.refreshInProgress) {
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
//    if ([identifier isEqualToString:@"edit"] && self.wasInvited) {
//        return NO;
//    } else {
//        return YES;
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"edit"]) {
        [segue.destinationViewController setEvent: self.event];
        [segue.destinationViewController setIsOwner: self.isOwner];
    } else if ([[segue identifier] isEqualToString:@"guests"]) {
        [segue.destinationViewController setGuests:self.event[@"who"]];
    } else if ([segue.identifier isEqualToString:@"where"]) {
        [segue.destinationViewController setYelpID:self.event[@"pid"]];
    }
}

-(IBAction)acceptInvite:(id)sender {
    //Attend Event
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/setAttending.php?eid=%@&uid=%@", self.event[@"id"], self.appDelegate.userID]];
    [NSData dataWithContentsOfURL:url];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

#pragma mark - Event Data Management

-(void)endFreshOnMain {
    [self.whenCell.detailTextLabel setText:self.event[@"dt"] != [NSNull null] ? [self.dfUI stringFromDate:self.event[@"dt"]] : @"Whenever"];
    [self.whereCell.detailTextLabel setText:self.event[@"place"] != [NSNull null] ? self.event[@"place"] : @"Wherever"];
    
    if (self.event[@"place"] != [NSNull null]) {
        [self.whereCell setUserInteractionEnabled:YES];
        self.whereCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        [self.whereCell setUserInteractionEnabled:NO];
        self.whereCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([self.event[@"who"] count] == 0) {
        self.whoCell.detailTextLabel.text = @"Whoever";
        [self.whoCell setUserInteractionEnabled:NO];
        self.whoCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        NSMutableString *attendees = [[NSMutableString alloc] init];
        for (NSDictionary *d in self.event[@"who"]) {
            if ([attendees length]) {
                [attendees appendString:@", "];
            }
            [attendees appendString: d[@"uname"]];
        }
        [self.whoCell setUserInteractionEnabled:YES];
        self.whoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.whoCell.detailTextLabel.text = attendees;
    }
    
    self.creatorCell.detailTextLabel.text = self.event[@"uname"];
    
    self.refreshInProgress = NO;
    [self.refreshControl endRefreshing];
}

-(void)refreshData {
    
    //Set up autoreleasepool beause this will be a thread?
    @autoreleasepool {
        
        //Grab the event info
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/event.php?id=%@", self.eventID]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *err;
        NSArray *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        self.event = [res objectAtIndex:0];
        
        //Grab the attending list
        url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/eventsAttending.php?eid=%@", self.eventID]];
        data = [NSData dataWithContentsOfURL:url];
        NSMutableArray *eAttending = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        [eAttending sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"uname"] compare:obj2[@"uname"]];
        }];
        
        [self.event setObject:eAttending forKey:@"who"];
        
        //Encode date object
        if (self.event[@"dt"] != [NSNull null]) {
            self.event[@"dt"] = [self.dfMySQL dateFromString:self.event[@"dt"]];
        }
        
        //Update the UI on the main thread
        [self performSelectorOnMainThread:@selector(endFreshOnMain) withObject:nil waitUntilDone:NO];
    }
}

@end
