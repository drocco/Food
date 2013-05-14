//
//  DRRDetailsTableViewController.h
//  Food?
//
//  Created by drocco on 5/10/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRRDetailsTableViewController : UITableViewController

@property (strong, atomic) NSString *eventID;
@property (atomic) BOOL isOwner;
@property (atomic) BOOL wasInvited;
@property (strong, nonatomic) IBOutlet UITableViewCell *whenCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *whereCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *whoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *creatorCell;

@end
