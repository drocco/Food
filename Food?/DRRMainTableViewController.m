//
//  DRRMainTableViewController.m
//  Food?
//
//  Created by drocco on 5/9/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import "DRRMainTableViewController.h"
#import "DRRAppDelegate.h"
#import "DRRDetailsTableViewController.h"
#import "DRREditTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DRRMainTableViewController ()

@property (weak, atomic) DRRAppDelegate *appDelegate;
@property (strong, atomic) NSMutableArray *events;
@property (strong, atomic) NSMutableArray *updatingEvents;
@property (strong, atomic) NSMutableArray *invitedEvents;
@property (strong, atomic) NSMutableArray *updatingInvitedEvents;
@property (atomic) BOOL refreshInProgress;
@property (strong, nonatomic) NSDateFormatter *dfMySQL;
@property (strong, nonatomic) NSDateFormatter *dfUI;

-(void)refresh;
-(void)refreshData;
-(void)deleteEvent:(NSString *)eid;
-(void)stopAttending:(NSString *)eid;
-(void)endFreshOnMain;

@end

@implementation DRRMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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
            self.appDelegate.userName = result.name;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"details"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setEventID: [self.events[indexPath.row] objectForKey:@"id"]];
        [segue.destinationViewController setWasInvited:NO];
        if ([self.appDelegate.userID isEqualToString:[self.events[indexPath.row] objectForKey:@"creator"]]) {
            [segue.destinationViewController setIsOwner: YES];
        } else {
            [segue.destinationViewController setIsOwner: NO];
        }
    } else if ([segue.identifier isEqualToString:@"new"]) {
        [segue.destinationViewController setEvent:nil];
    } else if ([segue.identifier isEqualToString:@"invited"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setEventID: [self.invitedEvents[indexPath.row] objectForKey:@"id"]];
        [segue.destinationViewController setWasInvited:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Invited";
    } else {
        return @"Attending";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return self.invitedEvents.count ?: 0;
    } else {
        return self.events.count ?: 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *InviteIdentifier = @"inviteEvent";
    static NSString *PlainIdentifier = @"plainEvent";
    UITableViewCell *cell;
    NSDictionary *dict;
    
    if (indexPath.section == 0 && self.invitedEvents.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:InviteIdentifier forIndexPath:indexPath];
        dict = [self.invitedEvents objectAtIndex:indexPath.row];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:PlainIdentifier forIndexPath:indexPath];
        dict = [self.events objectAtIndex:indexPath.row];
    }
    
    // Configure the cell...
    cell.textLabel.text = dict[@"place"] != [NSNull null] ? dict[@"place"] : @"Wherever";
    cell.detailTextLabel.text = dict[@"dt"] != [NSNull null] ? [self.dfUI stringFromDate:dict[@"dt"]] : @"Whenever";
    
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (indexPath.section == 0) {
            NSDictionary *dict = self.invitedEvents[indexPath.row];
            [self performSelectorInBackground:@selector(stopAttending:) withObject:[dict objectForKey:@"id"]];
            [self.invitedEvents removeObjectAtIndex:indexPath.row];
        } else {
            NSDictionary *dict = self.events[indexPath.row];
            if (([[dict objectForKey:@"creator"] isEqualToString:[self.appDelegate userID]])) {
                [self performSelectorInBackground:@selector(deleteEvent:) withObject:[dict objectForKey:@"id"]];
                [self.events removeObjectAtIndex:indexPath.row];
            } else {
                [self performSelectorInBackground:@selector(stopAttending:) withObject:[dict objectForKey:@"id"]];
                [self.events removeObjectAtIndex:indexPath.row];
            }
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


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
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

#pragma mark - Event Data Management

-(void)endFreshOnMain {
    self.events = self.updatingEvents;
    self.invitedEvents = self.updatingInvitedEvents;
    [self.tableView reloadData];
    self.refreshInProgress = NO;
    [self.refreshControl endRefreshing];
}

-(void)refreshData {
    
    //Set up pool because this is run as a thread??
    @autoreleasepool {
        
        //Grab the events created by the user
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/events.php?id=%@", [self.appDelegate userID]]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *err;
        self.updatingEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        //Grab the events the user is attending
        url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/eventsAttending.php?id=%@", [self.appDelegate userID]]];
        data = [NSData dataWithContentsOfURL:url];
        NSMutableArray *eAttending = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        //Append these events to the Array of events
        [self.updatingEvents addObjectsFromArray:eAttending];
        
        //Decode date strings
        for (NSMutableDictionary *d in self.updatingEvents) {
            if (d[@"dt"] != [NSNull null]) {
                d[@"dt"] = [self.dfMySQL dateFromString:d[@"dt"]];
            }
        }
        
        //Sort by date
        [self.updatingEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if (obj1[@"dt"] == [NSNull null] && obj2[@"dt"] == [NSNull null]) {
                return NSOrderedSame;
            }
            if (obj1[@"dt"] == [NSNull null]) {
                return NSOrderedAscending;
            }
            if (obj2[@"dt"] == [NSNull null]) {
                return NSOrderedDescending;
            }
            
            return [obj1[@"dt"] compare:obj2[@"dt"]];
        }];
        
        //Grab events I'm invited to
        url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/eventsInvited.php?id=%@", [self.appDelegate userID]]];
        data = [NSData dataWithContentsOfURL:url];
        self.updatingInvitedEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        //Decode date strings
        for (NSMutableDictionary *d in self.updatingInvitedEvents) {
            if (d[@"dt"] != [NSNull null]) {
                d[@"dt"] = [self.dfMySQL dateFromString:d[@"dt"]];
            }
        }
        
        //Sort by date
        [self.updatingInvitedEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if (obj1[@"dt"] == [NSNull null] && obj2[@"dt"] == [NSNull null]) {
                return NSOrderedSame;
            }
            if (obj1[@"dt"] == [NSNull null]) {
                return NSOrderedAscending;
            }
            if (obj2[@"dt"] == [NSNull null]) {
                return NSOrderedDescending;
            }
            
            return [obj1[@"dt"] compare:obj2[@"dt"]];
        }];
        
        //Update the UI on main thread
        [self performSelectorOnMainThread:@selector(endFreshOnMain) withObject:nil waitUntilDone:NO];
    }
}

-(void)deleteEvent:(NSString *)eid {
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/deleteevent.php?id=%@", eid]];
    NSError *err;
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&err];
    if (response.intValue != 0) {
        [[[UIAlertView alloc] initWithTitle:@"Delete Failed" message:@"Row could not be deleted" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
}

-(void)stopAttending:(NSString *)eid {
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/stopAttending.php?id=%@&eid=%@", [self.appDelegate userID], eid]];
    NSError *err;
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&err];
    if (response.intValue != 0) {
        [[[UIAlertView alloc] initWithTitle:@"Delete Failed" message:@"Row could not be deleted" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
}

@end
