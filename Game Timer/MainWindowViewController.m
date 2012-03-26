//
//  MainWindowViewController.m
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainWindowViewController.h"
#import <QuartzCore/QuartzCore.h>

const int MAX_HOURS   = 10;
const int MAX_PERIODS = 30;

@implementation MainWindowViewController


- (void) timeSettingsChanged
{
}


- (void) populateSettings:(TimerSettings *) settings
{
    [mainHour   setText:[NSString stringWithFormat:@"%d",   [settings hours_]]];
    [mainMinute setText:[NSString stringWithFormat:@"%02d", [settings minutes_]]];
    [mainSecond setText:[NSString stringWithFormat:@"%02d", [settings seconds_]]];
    
    [overtimeMinute setText:[NSString stringWithFormat:@"%02d", [settings overtimeMinutes_]]];
    [overtimeSecond setText:[NSString stringWithFormat:@"%02d", [settings overtimeSeconds_]]];
    [overtimePeriod setText:[NSString stringWithFormat:@"%02d", [settings overtimePeriods_]]];
    
    [self textFieldDidChange:mainHour];
    [self textFieldDidChange:mainMinute];
    [self textFieldDidChange:mainSecond];
    
    switch ([settings type_]) {
        case Absolute:
            [self disableOvertimeControls];
            [self disablePeriodControls];
            break;
        case Bronstein:
        case Fischer:
            [self disablePeriodControls];
            [self enableOvertimeControls];
            break;
        case ByoYomi:
        case Canadian:
            [self enablePeriodControls];
            [self enableOvertimeControls];
            break;
        case Hourglass:
            [self disableOvertimeControls];
            [self disablePeriodControls];
            break;
        default:;
    }
    
    

}


- (void) viewDidLoad
{
    // Connect the application's AppDelegate instance to this view
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Add a "textFieldDidChange" notification method to the text fields
	[overtimeMinute addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[overtimeSecond addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[overtimePeriod addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
	[mainHour   addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[mainMinute addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[mainSecond addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // round the corners
    
    [maintimeView.layer setCornerRadius:5.0f];
    [maintimeView.layer setMasksToBounds:YES];
    [overtimeView.layer setCornerRadius:5.0f];
    [overtimeView.layer setMasksToBounds:YES];
    [typesView.layer setCornerRadius:5.0f];
    [typesView.layer setMasksToBounds:YES];
    [timerTablesView.layer setCornerRadius:5.0f];
    [timerTablesView.layer setMasksToBounds:YES];
    
    // set defaults for the pickers
    
    // who goes first (black for go, white for chess)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger firstPlayer = [prefs integerForKey:@"First Player"];
    
    
    NSInteger lastTimerTableSelection = [prefs integerForKey:@"Last Timer Table Selection"];
    
    whiteBlack.selectedSegmentIndex = firstPlayer;
    historySavedBuiltin.selectedSegmentIndex = lastTimerTableSelection;
}


- (IBAction)segmentedClick:(UISegmentedControl *) sender
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if (sender == whiteBlack) {
        [prefs setInteger:[sender selectedSegmentIndex] forKey:@"First Player"];
    }
    else {
        [prefs setInteger:[sender selectedSegmentIndex] forKey:@"Last Timer Table Selection"];
        //TODO: history/saved/builtin => change table view
    }
    [prefs synchronize];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// ========================== TEXT FIELD METHODS ====================================

/**
 * When the text is entered via keyboard, update the appropriate picker
 */
- (void)textFieldDidChange:(UITextField *) textField
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
    if (pickerView == numberOfPeriods)
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

    
    if (pickerView == numberOfPeriods || 
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
    
    if (tableView == timerTypesTable)
        cell.textLabel.text = [[TimerSettings TimerTypes] objectAtIndex:[indexPath indexAtPosition:1]];
    else
        cell.textLabel.text = @"Placeholder";

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == timerTypesTable)
        return [[TimerSettings TimerTypes] count];
    if (tableView == savedTimersTable) {
        return 0;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath indexAtPosition:1];
    NSLog(@"Got %d", row);
    if (tableView == timerTypesTable) {
        ;
    }
    else if (tableView == savedTimersTable) {
    }
}

// ========================== VISABILITY METHODS ====================================


- (void) disablePeriodControls
{
    numberOfPeriods.hidden = YES;
    overtimePeriod.hidden  = YES;
}

- (void) disableOvertimeControls
{
    overtimeMinute.hidden = YES;
    overtimeSecond.hidden = YES;
    overtimeMinutesSeconds.hidden = YES;
}

- (void) enablePeriodControls
{
    numberOfPeriods.hidden = NO;
    overtimePeriod.hidden  = NO;
}

- (void) enableOvertimeControls
{
    overtimeMinute.hidden = NO;
    overtimeSecond.hidden = NO;
    overtimeMinutesSeconds.hidden = NO;
}


@end






