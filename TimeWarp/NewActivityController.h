//
//  NewActivityController.h
//  TimeWarp
//
//  Created by pat on 20.06.2013.
//  Copyright (c) 2013 zuehlke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import "SAMTextView.h"

@interface NewActivityController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray* projects;
@property (nonatomic, strong) Project* selectedProject;
@property (nonatomic, strong) Activity* activity;
@property (nonatomic, strong) NSArray* timeSlotIntervals;
@property (nonatomic, strong) NSDate* currentDate;

@property (nonatomic, strong) IBOutlet UITextField* timeTextField;
@property (nonatomic, strong) IBOutlet SAMTextView* noteTextView;
@property (nonatomic, strong) IBOutlet UIPickerView* pickerView;

@end
