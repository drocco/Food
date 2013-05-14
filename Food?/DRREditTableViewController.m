//
//  DRREditTableViewController.m
//  Food?
//
//  Created by drocco on 5/10/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import "DRREditTableViewController.h"
#import "DRRAppDelegate.h"
#import "DRRWherePickerTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DRREditTableViewController ()

@property (strong, nonatomic) UIDatePicker *dp;
@property (strong, nonatomic) NSDateFormatter *dfURL;
@property (strong, nonatomic) NSDateFormatter *dfUI;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

- (void)dateChanged;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (void)fillTextBoxAndDismiss:(NSString *)text;

@end

@implementation DRREditTableViewController

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
    
    //Set up DateFormatters for UI display and URL encoding
    self.dfURL = [[NSDateFormatter alloc] init];
    [self.dfURL setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [self.dfURL setDateFormat:@"yyyy-MM-dd%20HH:mm:ss"];
    self.dfUI = [[NSDateFormatter alloc] init];
    [self.dfUI setDateStyle:NSDateFormatterShortStyle];
    [self.dfUI setTimeStyle:NSDateFormatterShortStyle];
    
    self.dp = [[UIDatePicker alloc] init];
    [self.dp setMinuteInterval:15];
    [self.dp setMinimumDate:[NSDate date]];
    [self.dp addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    self.whenText.inputView = self.dp;
    
    if (self.event) {
        
        id place = self.event[@"place"];
        id dt = self.event[@"dt"];
        
        self.dp.date = dt != [NSNull null] ? self.event[@"dt"] : [NSDate date];
        
        self.whenText.text = dt != [NSNull null] ? [self.dfUI stringFromDate:dt] : @"Whenever";
        self.whereText.text = place != [NSNull null] ? place : @"Wherever";
        
        NSMutableString *attendees = [[NSMutableString alloc] init];
        NSMutableArray *updatedWho = [[NSMutableArray alloc] initWithCapacity:[self.event[@"who"] count]];
        for (NSDictionary *d in self.event[@"who"]) {
            if ([attendees length]) {
                [attendees appendString:@", "];
            }
            [attendees appendString: d[@"uname"]];
            NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] init];
            updatedDict[@"uid"] = [d[@"uid"] copy];
            updatedDict[@"uname"] = [d[@"uname"] copy];
            [updatedWho addObject:updatedDict];
        }
        
        self.updatedEvent[@"who"] = updatedWho;

        if (attendees.length == 0) {
            attendees = [NSMutableString stringWithString:@"Whoever"];
        } else {
            self.whoText.text = attendees;
        }
        
        self.updatedEvent = [[NSMutableDictionary alloc] init];
        self.updatedEvent[@"id"] = [self.event[@"id"] copy];
        self.updatedEvent[@"dt"] = [self.event[@"dt"] copy];
        self.updatedEvent[@"place"] = [self.event[@"place"] copy];
        self.updatedEvent[@"pid"] = [self.event[@"pid"] copy];
        self.updatedEvent[@"who"] = [[NSMutableArray alloc] init];
        self.updatedEvent[@"creator"] = [self.event[@"creator"] copy];
        self.updatedEvent[@"uname"] = [self.event[@"uname"]copy];
        for (NSString *s in self.event[@"who"]) {
            [self.updatedEvent[@"who"] addObject:[s copy]];
        }
    } else {
        self.dp.date = [NSDate date];
        self.updatedEvent = [[NSMutableDictionary alloc] init];
        self.updatedEvent[@"dt"] = [NSNull null];
        self.updatedEvent[@"place"] = [NSNull null];
        self.updatedEvent[@"pid"] = [NSNull null];
        self.updatedEvent[@"who"] = [[NSMutableArray alloc] init];
        self.updatedEvent[@"creator"] = [[(DRRAppDelegate *)[[UIApplication sharedApplication] delegate] userID] copy];
        self.updatedEvent[@"uname"] = [[(DRRAppDelegate *)[[UIApplication sharedApplication] delegate] userName] copy];
        self.updatedEvent[@"who"] = [[NSMutableArray alloc] init];
        
        self.navigationItem.rightBarButtonItem.title = @"Create";
    }
    
    if (self.isOwner) {
        self.navigationItem.rightBarButtonItem.title = @"Save";
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dateChanged {
    self.whenText.text = [self.dfUI stringFromDate:self.dp.date];
    self.updatedEvent[@"dt"] = self.dp.date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"place"]) {
        [segue.destinationViewController setParent: self];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)donePressed:(id)sender {
    
    //Make a list of all current user ids
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[self.event[@"who"] count]];
    for (NSDictionary *d in self.event[@"who"]) {
        [values addObject:d[@"uid"]];
    }
    
    //Make the strings for updating the attending people
    NSMutableString *idString = [[NSMutableString alloc] init];
    NSMutableString *nameString = [[NSMutableString alloc] init];
    for (NSDictionary *d in self.updatedEvent[@"who"]) {
        //If the user has not already been invited
        if (![values containsObject:d[@"uid"]]) {
            if (idString.length) {
                [idString appendString:@":"];
                [nameString appendString:@":"];
            }
            
            [idString appendString:[d[@"uid"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            [nameString appendString:[d[@"uname"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        }
    }
    
    if (self.event) {
        if (self.isOwner) {
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://drocco.fatcow.com/updateEvent.php?id=%@", self.updatedEvent[@"id"]];
            if (self.updatedEvent[@"dt"] != [NSNull null]) {
                [urlString appendFormat:@"&dt=%@", [self.dfURL stringFromDate:self.updatedEvent[@"dt"]]];
            }
            if (self.updatedEvent[@"place"] != [NSNull null]) {
                [urlString appendFormat:@"&place=%@", [self.updatedEvent[@"place"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
                [urlString appendFormat:@"&pid=%@", self.updatedEvent[@"pid"]];
            }
            NSURL *url = [[NSURL alloc] initWithString:urlString];
            NSError *err;
            [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&err];
            
            if (nameString.length) {
                NSURL *updateAttendingurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/addAttending.php?eid=%@&unames=%@&ids=%@",self.event[@"id"], nameString, idString]];
                [NSString stringWithContentsOfURL:updateAttendingurl encoding:NSASCIIStringEncoding error:&err];
            }
        }
    } else {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://drocco.fatcow.com/createEvent.php?uid=%@&uname=%@", self.updatedEvent[@"creator"], [self.updatedEvent[@"uname"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        if (self.updatedEvent[@"dt"] != [NSNull null]) {
            [urlString appendFormat:@"&dt=%@", [self.dfURL stringFromDate:self.updatedEvent[@"dt"]]];
        }
        if (self.updatedEvent[@"place"] != [NSNull null]) {
            [urlString appendFormat:@"&place=%@", [self.updatedEvent[@"place"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            [urlString appendFormat:@"&pid=%@", self.updatedEvent[@"pid"]];
        }
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSError *err;
        NSString *response = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&err];
        if (nameString.length) {
            NSURL *updateAttendingurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://drocco.fatcow.com/addAttending.php?eid=%@&unames=%@&ids=%@",response, nameString, idString]];
            [NSString stringWithContentsOfURL:updateAttendingurl encoding:NSASCIIStringEncoding error:&err];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FBFriendPickerDelegate

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [NSMutableString stringWithString:self.whoText.text];
    
    //Make a list of all current user ids
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[self.event[@"who"] count]];
    for (NSDictionary *d in self.event[@"who"]) {
        [values addObject:d[@"uid"]];
    }

    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        //Only add if the ID is new
        if (![values containsObject:user.id]) {
            
            //Make text to display
            if ([text length]) {
                [text appendString:@", "];
            }
            [text appendString:user.name];
            
            //Create a dict for each user
            NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
            d[@"uid"] = user.id;
            d[@"uname"] = user.name;
            
            //Add new user info to attending array
            [self.updatedEvent[@"who"] addObject:d];
        }
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"Whoever"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:[NSMutableString stringWithString:self.whoText.text]];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    self.whoText.text = text;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
    if (indexPath.row == 2) {
        if (self.friendPickerController == nil) {
            // Create friend picker, and get data loaded into it.
            self.friendPickerController = [[FBFriendPickerViewController alloc] init];
            self.friendPickerController.title = @"Pick Friends";
            self.friendPickerController.delegate = self;
        }
        
        [self.friendPickerController loadData];
        [self.friendPickerController clearSelection];
        
        [self presentViewController:self.friendPickerController animated:YES completion:nil];
    }
}

@end
