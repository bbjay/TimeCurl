//
//  NewActivityController.m
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import "NewActivityController.h"
#import "SelectTimeController.h"
#import "SlotInterval.h"
#import "AppDelegate.h"
#import "TimeUtils.h"
#import "ModelUtils.h"
#import "Project.h"


@interface NewActivityController ()
- (void) updateTimeField;
- (void) loadProjects;
- (double)doubleHourFromDate:(NSDate*)date;
@end

@implementation NewActivityController

#pragma mark custom methods

- (IBAction)doneSelectingTime:(UIStoryboardSegue *)segue {
    NSLog(@"Done selecting time");

    SelectTimeController* sourceController = segue.sourceViewController;
    self.timeSlotIntervals = sourceController.timeSlotIntervals;
    [self updateTimeField];
}

- (void) updateTimeField
{
    NSString* timeString = nil;
    for (SlotInterval* slotInterval in self.timeSlotIntervals) {
        NSString* slotString = [slotInterval description];
        timeString = timeString == nil ? slotString : [NSString stringWithFormat:@"%@, %@", timeString, slotString];
    }
    self.timeTextField.text = timeString;
}

- (IBAction)donePressed:(id)sender
{
    NSLog(@"NewActivityController: done pressed");
    
    if (self.activity == nil) {
        self.activity = [ModelUtils newActivity];
    }
    
    NSMutableSet* newSlots = [NSMutableSet set];
    for (SlotInterval* slot in self.timeSlotIntervals) {
        TimeSlot* newTimeSlot = [ModelUtils newTimeSlot];
        newTimeSlot.start = [TimeUtils dateForDate:self.currentDate andHour:slot.begin];
        newTimeSlot.end   = [TimeUtils dateForDate:self.currentDate andHour:slot.end];
        newTimeSlot.activity = self.activity;
        [newSlots addObject:newTimeSlot];
    }
    self.activity.timeslots = newSlots;
    self.activity.project = self.selectedProject;
    self.activity.note = self.noteTextView.text;
    [ModelUtils saveContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadProjects
{
    self.projects = [ModelUtils fetchAllProjects];
}

#pragma mark transitions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditTime"]) {

        if (self.activity != nil) {
            SelectTimeController* controller = (SelectTimeController*)segue.destinationViewController;
            controller.timeSlotIntervals = [NSMutableArray array];
            [controller.timeSlotIntervals addObjectsFromArray:self.timeSlotIntervals];
        }
        
    }
}

#pragma mark methods from UIPickerView (DataSource and Delegate)

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.projects count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Project* project = [self.projects objectAtIndex:row];
    return [NSString stringWithFormat:@"%@, %@", project.name, project.subname];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedProject = [self.projects objectAtIndex:row];
}

#pragma mark standard methods from UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadProjects];

    self.selectedProject = [self.projects objectAtIndex:0];
    
    if (self.activity != nil) {
        
        // init self.timeSlotIntervals
        NSMutableArray* slotArray = [NSMutableArray array];
        for (TimeSlot* timeSlot in self.activity.timeslots) {
            SlotInterval* slotInterval = [[SlotInterval alloc] init];
            slotInterval.begin = [self doubleHourFromDate:timeSlot.start];
            slotInterval.end   = [self doubleHourFromDate:timeSlot.end];
            [slotArray addObject:slotInterval];
        }
        self.timeSlotIntervals = slotArray;

        // pre-fill the fields
        self.selectedProject = self.activity.project;
        NSInteger selectedProjectIndex = [self.projects indexOfObject:self.activity.project];
        [self.pickerView selectRow:selectedProjectIndex inComponent:0 animated:NO];
        self.noteTextView.text = self.activity.note;
        [self updateTimeField];
        
        self.title = @"Edit Activity";
    }

}

- (double)doubleHourFromDate:(NSDate*)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:date];
    int hour = [components hour];
    int min  = [components minute];
    return (1.0 * hour) + ((min * 1.0) / 60.0);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
