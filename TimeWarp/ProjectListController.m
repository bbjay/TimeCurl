//
//  ProjectListControllerViewController.m
//  TimeWarp
//
//  Created by pat on 17.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "ProjectListController.h"
#import "Project.h"
#import "AppDelegate.h"
#import "AddProjectController.h"
#import "ModelUtils.h"


@interface ProjectListController ()
- (void) loadData;
@end

@implementation ProjectListController

- (void) loadData
{
    self.projects = [NSMutableArray arrayWithArray:[ModelUtils fetchAllProjects]];
    [self.tableView reloadData];
}


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

}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Transitions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditProject"]) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Project* project = [self.projects objectAtIndex:indexPath.row];
        AddProjectController* controller = (AddProjectController*)segue.destinationViewController;
        controller.project = project;

    }
}

#pragma mark - Edit Mode

- (IBAction)enterEditMode:(id)sender
{
    // Add the done button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"Done"
											  style:UIBarButtonItemStyleDone
											  target:self
											  action:@selector(leaveEditMode:)];

    self.backupButtonRight = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
	
    [self.tableView setEditing:YES animated:YES];
   
}

- (IBAction)leaveEditMode:(id)sender
{
    // Add the edit button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Edit"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(enterEditMode:)];

    self.navigationItem.rightBarButtonItem = self.backupButtonRight;
    self.backupButtonRight = nil;

    [self.tableView setEditing:NO animated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.projects count];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"ProjectCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel* nameLabel    = (UILabel*)[cell viewWithTag:100];
        UILabel* subnameLabel = (UILabel*)[cell viewWithTag:101];
        
        Project* project = [self.projects objectAtIndex:indexPath.row];
        nameLabel.text = project.name;
        subnameLabel.text = project.subname;
    }
    else {
        static NSString *CellIdentifier = @"NewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.rowToDelete = indexPath;
        Project* project = [self.projects objectAtIndex:self.rowToDelete.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:[NSString stringWithFormat:@"Are you sure that you want to delete the project '%@ %@'? It will also delete all activities using that project.", project.name, project.subname]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
        [alert show];
        
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

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && self.rowToDelete != nil) {
        
        Project* project = [self.projects objectAtIndex:self.rowToDelete.row];
        [self.projects removeObject:project];
        [ModelUtils deleteObject:project];
        [ModelUtils saveContext];
        
        [self.tableView deleteRowsAtIndexPaths:@[self.rowToDelete] withRowAnimation:UITableViewRowAnimationFade];
        self.rowToDelete = nil;

    }
    
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    self.rowToDelete = nil;
}

@end
