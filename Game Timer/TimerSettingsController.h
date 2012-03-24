//
//  TimerSettingsController.h
//  Game Timer
//
//  Created by Josh Guffin on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerSettingsController : UIViewController

{
    IBOutlet UIPickerView * hourMainPicker;
    IBOutlet UITextField  * hourMainField;
    IBOutlet UIPickerView * minuteMainPicker;
    IBOutlet UITextField  * minuteMainField;
    IBOutlet UIPickerView * secondMainPicker;
    IBOutlet UITextField  * secondMainField;
}

@end
