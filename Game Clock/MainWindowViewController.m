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


/*
 TODO:
  - define more built-in timers
 */

#import "MainWindowViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "TimerSupply.h"
#import "ActivatedTimer.h"

const int MAX_HOURS   = 10;
const int MAX_PERIODS = 30;

const float HIDDEN_ALPHA   = 0.0f;
const float DISABLED_ALPHA = 0.3f;
const float ENABLED_ALPHA  = 1.0f;

// indices
const unsigned BUILTIN_TIMERS_INDEX  = 0;
const unsigned FAVORITE_TIMERS_INDEX = 1;
const unsigned HISTORY_TIMERS_INDEX  = 2;
const unsigned SAVED_TIMERS_INDEX    = 3;
const unsigned PAUSED_TIMERS_INDEX   = 4;

@implementation MainWindowViewController


/**
 * Something in the UI changed the settings.  Note that this method _ALTERS_
 * the settings; it may set overtime min/sec to zero.  This is so that superfluous
 * settings don't get counted as changes: i.e. selecting Byoyomi 10+3x10 and then
 * selecting Absolute makes the 3x10 irrelevant, but we don't want to change the
 * UI in case the user wants to change back.
 */
- (void) alterTimerSettingsAccordingToUI
{
    TimerSettings * settings = [appDelegate settings];

    // main time settings
    [settings setHours:[mainHour.text intValue]];
    [settings setMinutes:[mainMinute.text intValue]];
    [settings setSeconds:[mainSecond.text intValue]];

    // overtime settings
    if (overtimePeriodPicker.userInteractionEnabled)
        [settings setOvertimePeriods:[overtimePeriod.text intValue]];
    else
        [settings setOvertimePeriods:0];

    if (overtimeMinutesSeconds.userInteractionEnabled) {
        [settings setOvertimeMinutes:[overtimeMinute.text intValue]];
        [settings setOvertimeSeconds:[overtimeSecond.text intValue]];
    }
    else {
        [settings setOvertimeMinutes:0];
        [settings setOvertimeSeconds:0];
    }
    
    // enable save/launch/alert buttons
    NSArray * existing = [appDelegate alreadyExists:settings];
    settingsDirty_ = existing == nil;
    settingsValid_ = [settings validateSettings] == nil;
    
    // update top description text
    [timerDescription setText:[settings description]];

    if (!settingsValid_) {
        // notify the user that there's a problem
        
        [self disable:saveButton];
        [self disable:launchButton];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [self enable:alertButton];
    }
    else {
        // enable save and launch buttons
        if (settingsDirty_) {
            [self enable:saveButton];
            [savedTimersTable deselectRowAtIndexPath:[savedTimersTable indexPathForSelectedRow] animated:YES];
        }
        else
            [self selectTableRowForStoredSettings:existing];

        [self enable:launchButton];
        
        // save as 'last settings'
        [appDelegate storeCurrentSettings];
        
        // hide the alert button
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [self disable:alertButton withAlpha:HIDDEN_ALPHA];
    }
}

- (void) selectTableRowForStoredSettings
{
    NSArray * existing = [appDelegate alreadyExists:[appDelegate settings]];
    [self selectTableRowForStoredSettings:existing];
}

- (void) selectTableRowForStoredSettings:(NSArray *) existing
{
    // find the correct row/segment
    NSArray * indices = [timerSupply indexForItem:[existing objectAtIndex:1]
                                     inCollection:[existing objectAtIndex:0]];
    [self disable:saveButton];

    // select the row/segment
    NSUInteger selectedSegment  = [[indices objectAtIndex:0] unsignedIntValue];
    NSUInteger selectedTableRow = [[indices objectAtIndex:1] unsignedIntValue];
    historySavedBuiltin.selectedSegmentIndex = selectedSegment;
    [savedTimersTable reloadData];

    [savedTimersTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedTableRow
                                                              inSection:0]
                                  animated:YES scrollPosition:UITableViewScrollPositionNone];
}


/**
 * Popup an explanation of why the settings are invalid when the user clicks on
 * the alert button.
 */
- (IBAction) invalidSettingsReason:(id) sender
{
    NSString * explanation = [[appDelegate settings] validateSettings];
    UIAlertView *message   = [[UIAlertView alloc] initWithTitle:@"Settings problem!"
                                                        message:explanation
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];

    [message show];
}

- (IBAction)launchTimer:(id)sender
{
    Player first = (whiteBlack.selectedSegmentIndex == 0 ? White : Black);
    [appDelegate launchWithPlayer:first];
    
    // load the timer window
    [self performSegueWithIdentifier:@"Launch" sender:nil];
}

- (IBAction)saveSettings:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save"
                                                     message:@"Please enter a name for the settings"
                                                    delegate:timerSupply
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Save",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertField = [alert textFieldAtIndex:0];
    [alertField setText:[[appDelegate settings] description]]; 

    [UIMenuController sharedMenuController].menuVisible = NO;
    [alertField selectAll:self];
    
    [alert show];
}


- (void) updateInterfaceToReflectNonDirtySettings
{
    settingsDirty_ = NO;
    [saveButton setEnabled:NO];
    [saveButton setAlpha:DISABLED_ALPHA];
    [self selectTableRowForStoredSettings];
}


/**
 * Update the display commensurate with the settings
 */
- (void) updateInterfaceAccordingToStoredSettings
{
    TimerSettings * settings = [appDelegate settings];

    // update the text fields
    [mainHour       setText:[NSString stringWithFormat:@"%d",   [settings hours]]];
    [mainMinute     setText:[NSString stringWithFormat:@"%02d", [settings minutes]]];
    [mainSecond     setText:[NSString stringWithFormat:@"%02d", [settings seconds]]];
    [overtimeMinute setText:[NSString stringWithFormat:@"%02d", [settings overtimeMinutes]]];
    [overtimeSecond setText:[NSString stringWithFormat:@"%02d", [settings overtimeSeconds]]];
    [overtimePeriod setText:[NSString stringWithFormat:@"%02d", [settings overtimePeriods]]];

    // update the time pickers
    [self updatePickersFromTextField:mainHour       changeSettings:NO];
    [self updatePickersFromTextField:mainMinute     changeSettings:NO];
    [self updatePickersFromTextField:mainSecond     changeSettings:NO];
    [self updatePickersFromTextField:overtimePeriod changeSettings:NO];
    [self updatePickersFromTextField:overtimeMinute changeSettings:NO];
    [self updatePickersFromTextField:overtimeSecond changeSettings:NO];

    TimerType type = [settings type];
    // enable/disable overtime periods/time settings as appropriate,
    // and select the correct element in the type table
    [self enableDisableOvertime:type];
    
    // update top description text
    [timerDescription setText:[settings description]];

    [self updateInterfaceToReflectNonDirtySettings];
}

/**
 * Helper for updateInterfaceAccordingToStoredSettings.  Selects the appropriate type in the table
 * view and enables/disables the appropriate controls.
 */
- (void) selectType:(TimerType) type
             period:(BOOL) pEnabled
           overtime:(BOOL) oEnabled
{
    NSUInteger i = [TimerSettings IndexForType:type];
    [timerTypesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                 animated:NO
                           scrollPosition:UITableViewScrollPositionNone];
    if (pEnabled)
        [self enablePeriodControls];
    else
        [self disablePeriodControls];

    if (oEnabled)
        [self enableOvertimeControls];
    else
        [self disableOvertimeControls];
}


#define ADD_NOTIFICATION(x) \
    [x addTarget:self action:@selector(textFieldDidChange:) \
            forControlEvents:UIControlEventEditingChanged];
#define ROUND_CORNER(x) \
    [x.layer setCornerRadius:5.0f]; \
    [x.layer setMasksToBounds:YES];

- (void) viewDidLoad
{
    // Connect the application's AppDelegate instance to this view
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    // Add a "textFieldDidChange" notification method to the text fields
    ADD_NOTIFICATION(overtimeMinute);
    ADD_NOTIFICATION(overtimeSecond);
    ADD_NOTIFICATION(overtimePeriod);
    ADD_NOTIFICATION(mainHour);
    ADD_NOTIFICATION(mainMinute);
    ADD_NOTIFICATION(mainSecond);

    // round the view corners
    ROUND_CORNER(descriptionView);
    ROUND_CORNER(maintimeView);
    ROUND_CORNER(overtimeView);
    ROUND_CORNER(typesView);
    ROUND_CORNER(timerTablesView);

    // who goes first (black for go, white for chess)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger firstPlayer = [prefs integerForKey:@"First Player"];
    whiteBlack.selectedSegmentIndex = firstPlayer;

    timerSupply = [[TimerSupply alloc] init:self delegate:appDelegate];
    savedTimersTableHasData_ = YES;
    [self disable:alertButton withAlpha:0.0f];

    [self updateInterfaceAccordingToStoredSettings];
    [savedTimersTable reloadData];
    [self selectTableRowForStoredSettings];
}

#undef ROUND_CORNER
#undef ADD_NOTIFICATION

/**
 * Target for segmented control clicks
 */
- (IBAction)segmentedClick:(UISegmentedControl *) sender
{
    if (sender == whiteBlack) {
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:[sender selectedSegmentIndex] forKey:@"First Player"];
        [prefs synchronize];
    }
    else
        [savedTimersTable reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO: pause and store timer settings
}

// ========================== TEXT FIELD METHODS ====================================

/**
 * When the text is entered via keyboard, update the appropriate picker
 */
- (void)textFieldDidChange:(UITextField *) textField
{
    [self updatePickersFromTextField:textField changeSettings:YES];
}


/**
 * Text Field change delegate helper.  If 'alter' is true, then call
 * alterTimerSettingsAccordingToUI
 */
- (void)updatePickersFromTextField:(UITextField *) textField
                    changeSettings:(BOOL) alter
{
    // validate
    NSInteger value = [[textField text] intValue];
    if (value < 0) {
        value = 0;
        [textField setText:@"0"];
    }

    // validate
    if (value > 59) {
        value = 59;
        [textField setText:@"59"];
    }

    // update the appropriate picker
    if (textField == mainHour)
        [mainTimePicker selectRow:value inComponent:0 animated:NO];
    else if (textField == mainMinute)
        [mainTimePicker selectRow:value inComponent:1 animated:NO];
    else if (textField == mainSecond)
        [mainTimePicker selectRow:value inComponent:2 animated:NO];
    else if (textField == overtimePeriod)
        [overtimePeriodPicker selectRow:value inComponent:0 animated:NO];
    else if (textField == overtimeMinute)
        [overtimeMinutesSeconds selectRow:value inComponent:0 animated:NO];
    else if (textField == overtimeSecond)
        [overtimeMinutesSeconds selectRow:value inComponent:1 animated:NO];

    if (alter)
        [self alterTimerSettingsAccordingToUI];
}

// ========================== PICKER METHODS ====================================

/**
 * When the picker is set, update the corresponding text box.
 */
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    if (pickerView == mainTimePicker)
    {
        if (component == 0)
            [mainHour setText:[NSString stringWithFormat:@"%d", row]];
        else if (component == 1)
            [mainMinute setText:[NSString stringWithFormat:@"%02d", row]];
        else
            [mainSecond setText:[NSString stringWithFormat:@"%02d", row]];

    }
    else if (pickerView == overtimeMinutesSeconds)
    {
        if (component == 0)
            [overtimeMinute setText:[NSString stringWithFormat:@"%02d", row]];
        else
            [overtimeSecond setText:[NSString stringWithFormat:@"%02d", row]];
    }
    else
    {
        [overtimePeriod setText:[NSString stringWithFormat:@"%d", row]];
    }

    [self alterTimerSettingsAccordingToUI];
}

// Time picker datasource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == mainTimePicker)
        return 3;
    if (pickerView == overtimeMinutesSeconds)
        return 2;

    // # of periods picker
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == overtimePeriodPicker)
        return MAX_PERIODS;

    // hours component of main time picker
    if (pickerView == mainTimePicker && component == 0)
        return MAX_HOURS;

    // min/sec
    return 60;
}

/**
 * Create the elements shown in the pickers
 */
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel *label        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 37)];
    label.textAlignment   = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font            = [UIFont boldSystemFontOfSize:20];

    // show the possibly zero-padded row number
    if (pickerView == overtimePeriodPicker ||
        (pickerView == mainTimePicker && component == 0))
        label.text = [NSString stringWithFormat:@"%d", row];
    else
        label.text = [NSString stringWithFormat:@"%02d", row];

    return label;
}


// ========================== TABLEVIEW METHODS ====================================

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = CGRectMake(0, 0, 200, 37);

    UITableViewCell * cell   = [[UITableViewCell alloc] initWithFrame:frame];
    cell.backgroundColor     = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    NSUInteger row           = [indexPath indexAtPosition:1];

    if (tableView == timerTypesTable)
        cell.textLabel.text = [[TimerSettings TimerTypes] objectAtIndex:row];
    else {
        if (savedTimersTableHasData_) {
            NSString * text = [timerSupply titleForItem:row 
                                            inComponent:historySavedBuiltin.selectedSegmentIndex];
            cell.textLabel.text = text;
        }
        else {
            NSString * table = [[TimerSupply keys] objectAtIndex:historySavedBuiltin.selectedSegmentIndex];
            cell.textLabel.text = [NSString stringWithFormat:@"No %@ items exist", table];
        }
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == timerTypesTable)
        return [[TimerSettings TimerTypes] count];
    if (tableView == savedTimersTable) {
        NSInteger count = [timerSupply rowsInComponent:historySavedBuiltin.selectedSegmentIndex];
        if (count == 0) {
            savedTimersTableHasData_ = NO;
            return 1;
        }
        savedTimersTableHasData_ = YES;
        return count;
    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath indexAtPosition:1];
    // TODO: Finish it!
    if (tableView == timerTypesTable) {
        TimerSettings * timer = [appDelegate settings];
        TimerType type = (TimerType) row;

        // settings changed
        if (type != [timer type]) {
            [timer setType:type];
            [self enableDisableOvertime:type];
            [self alterTimerSettingsAccordingToUI];
        }
    }
    else if (tableView == savedTimersTable) {
        unsigned component = historySavedBuiltin.selectedSegmentIndex;
        TimerSettings * selected = [timerSupply timerForItem:row inComponent:component];
        if (selected == nil)
            NSLog(@"There was a nil selection at %d, %d", row, component);
        else {
            [appDelegate setSettings:selected];
            [self updateInterfaceAccordingToStoredSettings];
        }
        
        [appDelegate storeCurrentSettings];
    }
}


/**
 * Overridden so that we can display cells denoting empty data that are not selectable
 */
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == timerTypesTable)
        return indexPath;
    
    if (savedTimersTableHasData_)
        return indexPath;

    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == timerTypesTable)
        return NO;
    
    return (savedTimersTableHasData_ &&
            (historySavedBuiltin.selectedSegmentIndex == SAVED_TIMERS_INDEX ||
             historySavedBuiltin.selectedSegmentIndex == FAVORITE_TIMERS_INDEX));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // just in case
    if (tableView == timerTypesTable)
        return;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        unsigned component = historySavedBuiltin.selectedSegmentIndex;
        [timerSupply deleteTimerAtIndexPath:indexPath inComponent:component];
        [tableView reloadData];
    }    
}


// ========================== VISABILITY METHODS ====================================

- (void) enableDisableOvertime:(TimerType) type
{
    switch (type) {
        case Absolute:
            [self selectType:type period:NO overtime:NO];
            break;
        case Bronstein:
            [self selectType:type period:NO overtime:YES];
            break;
        case Fischer:
            [self selectType:type period:NO overtime:YES];
            break;
        case ByoYomi:
            [self selectType:type period:YES overtime:YES];
            break;
        case Canadian:
            [self selectType:type period:YES overtime:YES];
            break;
        case Hourglass:
            [self selectType:type period:NO overtime:NO];
            break;
        default:;
    }
}


- (void) enable:(id) uiElement
{
    [uiElement setAlpha:ENABLED_ALPHA];
    [uiElement setEnabled:YES];
}

- (void) disable:(id) uiElement withAlpha:(CGFloat) alpha
{
    [uiElement setAlpha:alpha];
    [uiElement setEnabled:NO];
}

- (void) disable:(id) uiElement
{
    [self disable:uiElement withAlpha:DISABLED_ALPHA];
}

- (void) enablePicker:(UIPickerView *) pv
{
    [pv setAlpha:ENABLED_ALPHA];
    pv.userInteractionEnabled = YES;
}

- (void) disablePicker:(UIPickerView *) pv
{
    [pv setAlpha:DISABLED_ALPHA];
    pv.userInteractionEnabled = NO;
}

- (void) disablePeriodControls
{
    [self disable:overtimePeriod];
    [self disablePicker:overtimePeriodPicker];
}

- (void) disableOvertimeControls
{
    [self disable:overtimeMinute];
    [self disable:overtimeSecond];

    [self disablePicker:overtimeMinutesSeconds];
}

- (void) enablePeriodControls
{
    [self enable:overtimePeriod];
    [self enablePicker:overtimePeriodPicker];
}

- (void) enableOvertimeControls
{
    [self enable:overtimeMinute];
    [self enable:overtimeSecond];

    [self enablePicker:overtimeMinutesSeconds];
}


@end
