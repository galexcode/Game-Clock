// Copyright 2012 Josh Guffin
//
// This file is part of Game Clock
//
// Game Clock is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Game Clock is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// Game Clock. If not, see http://www.gnu.org/licenses/.

#ifndef MainWindowViewController_h_included
#define MainWindowViewController_h_included

#import <UIKit/UIKit.h>

#import "TimerSettings.h"
@class AppDelegate;
@class TimerSupply;

const unsigned BUILTIN_TIMERS_INDEX;
const unsigned FAVORITE_TIMERS_INDEX;
const unsigned HISTORY_TIMERS_INDEX;
const unsigned SAVED_TIMERS_INDEX;
const unsigned PAUSED_TIMERS_INDEX;

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
    IBOutlet UIButton * alertButton;
    
    // upper table view
    IBOutlet UITableView * timerTypesTable;

    // lower table view
    IBOutlet UITableView * savedTimersTable;
    BOOL savedTimersTableHasData_;

    // TimerSupply handles the lower table view's data
    TimerSupply * timerSupply;

    IBOutlet UISegmentedControl * whiteBlack;
    IBOutlet UISegmentedControl * historySavedBuiltin;
    
    IBOutlet UILabel * timerDescription;
    
    // managed settings
    AppDelegate * appDelegate;

    BOOL settingsDirty_;
    BOOL settingsValid_;
}

- (IBAction)launchTimer:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)textFieldNextButton:(id) sender;
- (IBAction)invalidSettingsReason:(id) sender;
- (IBAction)segmentedClick:(UISegmentedControl *) sender;


// helpers for interaction management
- (void) alterTimerSettingsAccordingToUI;
- (void) updateInterfaceToReflectNonDirtySettings;
- (void) updateInterfaceAccordingToStoredSettings;
- (void) selectType:(TimerType) type period:(BOOL) pEnabled overtime:(BOOL) oEnabled;

// text field delegates/helpers
- (void) selectAndRespond:(UITextField *) tf;
- (void) textFieldDidChange:(UITextField *) textField;
- (void) updatePickersFromTextField:(UITextField *) textField changeSettings:(BOOL) alter;

// table element selection
- (void) selectTableRowForStoredSettings:(NSArray *) existing;
- (void) selectTableRowForStoredSettings;

// enable/disable controls based on timer type
- (void) enableDisableOvertime:(TimerType) type;
- (void) disablePeriodControls;
- (void) disableOvertimeControls;
- (void) enablePeriodControls;
- (void) enableOvertimeControls;

- (void) enable:(id) uiElement;
- (void) disable:(id) uiElement;
- (void) disable:(id) uiElement withAlpha:(CGFloat) alpha;
- (void) enablePicker:(UIPickerView *) pv;
- (void) disablePicker:(UIPickerView *) pv;

@end

#endif
