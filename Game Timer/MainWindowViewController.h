//
//  MainWindowViewController.h
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TimerSettings.h"

@interface MainWindowViewController : UIViewController 
<UIPickerViewDelegate, 
 UIPickerViewDataSource,
 UITableViewDelegate,
 UITableViewDataSource>
{
    IBOutlet UITextField * mainHour;
    IBOutlet UITextField * mainMinute;
    IBOutlet UITextField * mainSecond;
    IBOutlet UITextField * overtimeMinute;
    IBOutlet UITextField * overtimeSecond;
    IBOutlet UITextField * overtimePeriod;
    
    IBOutlet UIPickerView * mainTimePicker;
    IBOutlet UIPickerView * overtimeMinutesSeconds;
    IBOutlet UIPickerView * numberOfPeriods;
    
    // round their corners
    IBOutlet UIView * typesView;       // top left
    IBOutlet UIView * maintimeView;    // top middle
    IBOutlet UIView * overtimeView;    // top right
    IBOutlet UIView * timerTablesView; // bottom
    
    // upper table view
    IBOutlet UITableView * timerTypesTable;
    
    // lower table views
    IBOutlet UITableView * categoriesTable;
    IBOutlet UITableView * savedTimersTable;
    
    AppDelegate * appDelegate;
}

- (IBAction)selectNewTimer:(id)sender;
- (IBAction)selectFavorites:(id)sender;

- (void) timeSettingsChanged;
- (void) populateSettings:(TimerSettings *) settings;
- (void)textFieldDidChange:(UITextField *) textField;

- (void) disablePeriodControls;
- (void) disableOvertimeControls;
- (void) enablePeriodControls;
- (void) enableOvertimeControls;

@end
