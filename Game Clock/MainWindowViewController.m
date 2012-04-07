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

/*
 TODO:
 1) define a TimerSettings object to manipulate with the pickers/table view
 2) Make clicking on table elements select the timer (both timerTypesTable and selectedTimersTable
 3) define more built-in timers
 4) Periods cannot be zero for by/canadian; have type-specific maxima/minima
 5)
 */

#import "MainWindowViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "TimerSupply.h"

const int MAX_HOURS   = 10;
const int MAX_PERIODS = 30;

const float HIDDEN_ALPHA   = 0.0f;
const float DISABLED_ALPHA = 0.3f;
const float ENABLED_ALPHA  = 1.0f;

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

    NSArray * existing = [appDelegate alreadyExists:settings];
    settingsDirty_ = existing == nil;
    settingsValid_ = [settings validateSettings] == nil;

    if (!settingsValid_) {
        // notify the user that there's a problem
        [self enable:alertButton];
        [self disable:saveButton];
        [self disable:launchButton];
    }
    else {
        // enable save and launch buttons
        if (settingsDirty_) {
            [self enable:saveButton];
            [savedTimersTable deselectRowAtIndexPath:[savedTimersTable indexPathForSelectedRow] animated:YES];
        }
        else
            [self selectTableRowForStoredSettings:existing];

        [self disable:alertButton withAlpha:HIDDEN_ALPHA];
        [self enable:launchButton];
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
    [savedTimersTable reloadData];
    [self disable:saveButton];

    // select the row/segment
    NSUInteger selectedSegment  = [[indices objectAtIndex:0] unsignedIntValue];
    NSUInteger selectedTableRow = [[indices objectAtIndex:1] unsignedIntValue];
    historySavedBuiltin.selectedSegmentIndex = selectedSegment;
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

}

- (IBAction)saveSettings:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save"
                                                     message:@"Please enter a name for the settings"
                                                    delegate:timerSupply
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Save",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


- (void) updateInterfaceToReflectNonDirtySettings
{
    settingsDirty_ = NO;
    [saveButton setEnabled:NO];
    [saveButton setAlpha:DISABLED_ALPHA];
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
    ROUND_CORNER(maintimeView);
    ROUND_CORNER(overtimeView);
    ROUND_CORNER(typesView);
    ROUND_CORNER(timerTablesView);

    // who goes first (black for go, white for chess)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger firstPlayer = [prefs integerForKey:@"First Player"];
    whiteBlack.selectedSegmentIndex = firstPlayer;

    timerSupply = [[TimerSupply alloc] init:self delegate:appDelegate];
    savedTimersTableHasData = YES;
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
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if (sender == whiteBlack) {
        [prefs setInteger:[sender selectedSegmentIndex] forKey:@"First Player"];
    }
    else {
        selectedTableType = historySavedBuiltin.selectedSegmentIndex;
        [savedTimersTable reloadData];
    }
    [prefs synchronize];
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
        if (savedTimersTableHasData) {
        NSString * text = [timerSupply titleForItem:row inComponent:selectedTableType];
        cell.textLabel.text = text;
        }
        else {
            NSString * table = [[TimerSupply keys] objectAtIndex:selectedTableType];
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
        NSInteger count = [timerSupply rowsInComponent:selectedTableType];
        if (count == 0) {
            savedTimersTableHasData = NO;
            return 1;
        }
        savedTimersTableHasData = YES;
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
    }
}


/**
 * Make navigation between text fields easy
 */
- (IBAction) textFieldNextButton:(id) sender
{
    if (sender == mainHour) {
        [self selectAndRespond:mainMinute];
    }
    else if (sender == mainMinute) {
        [self selectAndRespond:mainSecond];
    }
    else if (sender == mainSecond) {
        if (overtimePeriod.enabled)
            [self selectAndRespond:overtimePeriod];
        else if (overtimeMinute.enabled)
            [self selectAndRespond:overtimeMinute];
    }
    else if (sender == overtimePeriod)
        [self selectAndRespond:overtimeMinute];
    else if (sender == overtimeSecond)
        [sender resignFirstResponder];
}

/**
 * Helper for textFieldNextButton
 */
- (void) selectAndRespond:(UITextField *) tf
{
    [tf selectAll:self];
    [tf becomeFirstResponder];
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
