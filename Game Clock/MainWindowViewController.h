// Copyright 2012 Josh Guffin
//
// This file is part of Game Clock
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    IBOutlet UIView * descriptionView; // top bar
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
- (IBAction)invalidSettingsReason:(id) sender;
- (IBAction)segmentedClick:(UISegmentedControl *) sender;


// helpers for interaction management
- (void) alterTimerSettingsAccordingToUI;
- (void) updateInterfaceToReflectNonDirtySettings;
- (void) updateInterfaceAccordingToStoredSettings;
- (void) selectType:(TimerType) type period:(BOOL) pEnabled overtime:(BOOL) oEnabled;

// text field delegates/helpers
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
