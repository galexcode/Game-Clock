//
//  MainWindowViewController.h
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TimerSupply.h"
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
    IBOutlet UIPickerView * overtimePeriodPicker;

    // round their corners
    IBOutlet UIView * typesView;       // top left
    IBOutlet UIView * maintimeView;    // top middle
    IBOutlet UIView * overtimeView;    // top right
    IBOutlet UIView * timerTablesView; // bottom

    // Buttons
    IBOutlet UIButton * saveButton;
    IBOutlet UIButton * launchButton;

    // upper table view
    IBOutlet UITableView * timerTypesTable;

    // lower table view
    IBOutlet UITableView * savedTimersTable;
    NSUInteger selectedTableType;
    BOOL savedTimersTableHasData;

    // TimerSupply handles the lower table view's data
    TimerSupply * timerSupply;

    IBOutlet UISegmentedControl * whiteBlack;
    IBOutlet UISegmentedControl * historySavedBuiltin;

    AppDelegate * appDelegate;

    BOOL settingsDirty_;
}
- (IBAction)textFieldNextButton:(id) sender;
- (IBAction)segmentedClick:(UISegmentedControl *) sender;

// helpers for interaction management
- (void)updatePickersFromTextField:(UITextField *) textField;
- (void) timeSettingsChanged;
- (void) selectAndRespond:(UITextField *) tf;
- (void) timerSetFromStoredType;
- (void) selectType:(TimerType) type period:(BOOL) pEnabled overtime:(BOOL) oEnabled;
- (void) populateSettings:(TimerSettings *) settings;
- (void)textFieldDidChange:(UITextField *) textField;

// enable/disable controls based on timer type
- (void) disablePeriodControls;
- (void) disableOvertimeControls;
- (void) enablePeriodControls;
- (void) enableOvertimeControls;

- (void) enableTextField:(UITextField *) tf;
- (void) disableTextField:(UITextField *) tf;
- (void) enablePicker:(UIPickerView *) pv;
- (void) disablePicker:(UIPickerView *) pv;

@end
