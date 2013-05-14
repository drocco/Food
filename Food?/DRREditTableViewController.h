//
//  DRREditTableViewController.h
//  Food?
//
//  Created by drocco on 5/10/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface DRREditTableViewController : UITableViewController <FBFriendPickerDelegate>

@property (strong, nonatomic) NSMutableDictionary *event;
@property (strong, nonatomic) NSMutableDictionary *updatedEvent;
@property (atomic) BOOL isOwner;
@property (strong, nonatomic) IBOutlet UITextField *whenText;
@property (strong, nonatomic) IBOutlet UITextField *whereText;
@property (strong, nonatomic) IBOutlet UITextField *whoText;

@end
