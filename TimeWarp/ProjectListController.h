//
//  ProjectListControllerViewController.h
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ProjectListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSArray* projects;

// backup of the + button item (during edition)
@property (nonatomic, strong) UIBarButtonItem* backupButtonRight;

@end
