//
//  MainWindowViewController.h
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MainWindowViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UITabBar * tabBar;
    
    IBOutlet UITextField * mainHour;
    IBOutlet UITextField * mainMinute;
    IBOutlet UITextField * mainSecond;
    IBOutlet UITextField * overtimeMinute;
    IBOutlet UITextField * overtimeSecond;
    IBOutlet UITextField * overtimePeriod;
    
    IBOutlet UIPickerView * mainTimePicker;
    IBOutlet UIPickerView * overtimeMinutesSeconds;
    IBOutlet UIPickerView * numberOfPeriods;
    
    AppDelegate * appDelegate;
}

- (IBAction)selectNewTimer:(id)sender;
- (IBAction)selectFavorites:(id)sender;


/* Tab bar delegate methods */
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
@end
