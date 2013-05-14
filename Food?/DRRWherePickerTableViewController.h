//
//  DRRWherePickerTableViewController.h
//  Food?
//
//  Created by drocco on 5/13/13.
//  Copyright (c) 2013 drocco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRREditTableViewController.h"

@interface DRRWherePickerTableViewController : UITableViewController <UISearchBarDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) DRREditTableViewController *parent;

@end
