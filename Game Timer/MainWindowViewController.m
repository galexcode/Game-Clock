// Copyright 2012 Josh Guffin
//
// This file is part of Game Timer
//
// Game Timer is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Game Timer is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// Game Timer. If not, see http://www.gnu.org/licenses/.

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

const float DISABLED_ALPHA = 0.3f;
const float ENABLED_ALPHA  = 1.0f;

@implementation MainWindowViewController


- (void) timeSettingsChanged
{

    TimerSettings * timer = [appDelegate settings];

    [timer setHours:[mainHour.text intValue]];
    [timer setMinutes:[mainMinute.text intValue]];
    [timer setSeconds:[mainSecond.text intValue]];

    if (overtimePeriodPicker.userInteractionEnabled)
        [timer setOvertimePeriods:[overtimePeriod.text intValue]];
    else 
        [timer setOvertimePeriods:0];

    if (overtimePeriodPicker.userInteractionEnabled) {
        [timer setOvertimeMinutes:[overtimeMinute.text intValue]];
        [timer setOvertimeSeconds:[overtimeSecond.text intValue]];
    }
    else {
        [timer setOvertimeMinutes:0];
        [timer setOvertimeSeconds:0];
    }

    settingsDirty_ = YES;
    [saveButton setEnabled:YES];
    [saveButton setAlpha:ENABLED_ALPHA];
}

- (void) timerSetFromStoredType
{
    settingsDirty_ = NO;
    [saveButton setEnabled:NO];
    [saveButton setAlpha:DISABLED_ALPHA];
}


/**
 * Update the display commensurate with the settings
 */
- (void) populateSettings:(TimerSettings *) settings
{
    // update the text fields
    [mainHour   setText:[NSString stringWithFormat:@"%d",   [settings hours]]];
    [mainMinute setText:[NSString stringWithFormat:@"%02d", [settings minutes]]];
    [mainSecond setText:[NSString stringWithFormat:@"%02d", [settings seconds]]];

    [overtimeMinute setText:[NSString stringWithFormat:@"%02d", [settings overtimeMinutes]]];
    [overtimeSecond setText:[NSString stringWithFormat:@"%02d", [settings overtimeSeconds]]];
    [overtimePeriod setText:[NSString stringWithFormat:@"%02d", [settings overtimePeriods]]];

    // update the time pickers
    [self textFieldDidChange:mainHour];
    [self textFieldDidChange:mainMinute];
    [self textFieldDidChange:mainSecond];
    [self textFieldDidChange:overtimePeriod];
    [self textFieldDidChange:overtimeMinute];
    [self textFieldDidChange:overtimeSecond];

    // enable/disable overtime periods/time settings as appropriate,
    // and select the correct element in the type table
    TimerType type = [settings type];

    [self enableDisableOvertime:type];

    [self timerSetFromStoredType];
    [savedTimersTable reloadData];
}

/**
 * Helper for populateSettings.  Selects the appropriate type in the table
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
    else {
        [self disablePeriodControls];
        NSLog(@"Disabled period controls");
    }

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

    // the last selected timer table
    selectedTableType = [prefs integerForKey:@"Last Timer Table Selection"];
    historySavedBuiltin.selectedSegmentIndex = selectedTableType;

    timerSupply = [[TimerSupply alloc] init];
    savedTimersTableHasData = YES;

    // last selected timer settings
    NSDictionary * lastTimerDict = [prefs dictionaryForKey:@"Last Timer Settings"];
    TimerSettings * lastTimer    = [[TimerSettings alloc] initWithDictionary:lastTimerDict];

    [appDelegate setSettings:lastTimer];
    [self populateSettings:lastTimer];
    [savedTimersTable reloadData];
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
        [prefs setInteger:selectedTableType forKey:@"Last Timer Table Selection"];
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
    [self updatePickersFromTextField:textField];
    [self timeSettingsChanged];
}

- (void)updatePickersFromTextField:(UITextField *) textField
{
    NSInteger value = [[textField text] intValue];
    if (value < 0) {
        value = 0;
        [textField setText:@"0"];
    }

    if (value > 59) {
        value = 59;
        [textField setText:@"59"];
    }

    if (textField == mainHour) {
        if (value > 59) {
            value = 59;
            [textField setText:@"59"];
        }

        [mainTimePicker selectRow:value inComponent:0 animated:NO];
    }
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

    [self timeSettingsChanged];
}

// ========================== PICKER METHODS ====================================

/**
 * When the picker is set, update the corresponding text box.
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
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

    [self timeSettingsChanged];
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

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel *label        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 37)];
    label.textAlignment   = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20];


    if (pickerView == overtimePeriodPicker ||
        (pickerView == mainTimePicker && component == 0))
        label.text = [NSString stringWithFormat:@"%d", row];
    else
        label.text = [NSString stringWithFormat:@"%02d", row];

    return label;
}


// ========================== TABLEVIEW METHODS ====================================

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    NSLog(@"Got %d", row);
    // TODO: Finish it!
    if (tableView == timerTypesTable) {
        TimerSettings * timer = [appDelegate settings];
        TimerType type = (TimerType) row;
        [timer setType:type];
        [self enableDisableOvertime:type];

        NSLog(@"Selected %@",[TimerSettings StringForType:type]);
    }
    else if (tableView == savedTimersTable) {
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


- (void) enableTextField:(UITextField *) tf
{
    [tf setAlpha:ENABLED_ALPHA];
    [tf setEnabled:YES];
}

- (void) disableTextField:(UITextField *) tf
{
    [tf setAlpha:DISABLED_ALPHA];
    [tf setEnabled:NO];
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
    NSLog(@"Called %s", __FUNCTION__);
    [self disableTextField:overtimePeriod];
    [self disablePicker:overtimePeriodPicker];
}

- (void) disableOvertimeControls
{
    [self disableTextField:overtimeMinute];
    [self disableTextField:overtimeSecond];

    [self disablePicker:overtimeMinutesSeconds];
}

- (void) enablePeriodControls
{
    [self enableTextField:overtimePeriod];
    [self enablePicker:overtimePeriodPicker];
}

- (void) enableOvertimeControls
{
    [self enableTextField:overtimeMinute];
    [self enableTextField:overtimeSecond];

    [self enablePicker:overtimeMinutesSeconds];
}


@end

