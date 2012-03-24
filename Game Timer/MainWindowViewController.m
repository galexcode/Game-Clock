//
//  MainWindowViewController.m
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainWindowViewController.h"

const int MAX_HOURS   = 10;
const int MAX_PERIODS = 30;

@implementation MainWindowViewController

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
}

- (IBAction)selectNewTimer:(id)sender
{
    NSLog(@"selected new");
}

- (IBAction)selectFavorites:(id)sender
{
    NSLog(@"selected favorites");
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = [item tag];

    NSLog(@"Dropped a %d BIITCH!!!!", tag);
    
    [self performSegueWithIdentifier:@"Create" sender:item];
}

// text box delegate method

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
}

// picker delegate method
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // set corresponding text box string
    if (pickerView == mainTimePicker)
    {
        if (component == 0)
            [mainHour setText:[NSString stringWithFormat:@"%02d", row]];
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

    
    if (pickerView == numberOfPeriods)
        label.text = [NSString stringWithFormat:@"%d", row];
    else
        label.text = [NSString stringWithFormat:@"%02d", row];
        
    return label;
}

@end






