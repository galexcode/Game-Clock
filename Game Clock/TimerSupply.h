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

#ifndef TimerSupply_h_included
#define TimerSupply_h_included

#import <Foundation/Foundation.h>
@class TimerSettings;
@class MainWindowViewController;
@class AppDelegate;

@interface TimerSupply : NSObject <UIAlertViewDelegate>
{
    MainWindowViewController * mwvc;
    AppDelegate * delegate;
    NSUserDefaults *prefs;
    NSDictionary * timers;
    
    // for the save confirmation dialogue
    NSString * toBeConfirmedSaveName;
}

-(id)init:(MainWindowViewController *) _mwvc delegate:(AppDelegate *) _delegate;

// save dialog delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// initial program load pref creation
- (void) createTimersFromDictionary:(NSDictionary *) dict;
- (void) createInitialObjects;

// table view helpers
- (NSUInteger) rowsInComponent:(NSUInteger) component;
- (NSString *) titleForItem:(NSUInteger) row inComponent:(NSUInteger) component;
- (NSArray *) indexForItem:(NSString *) description inCollection:(NSString *) collection;
- (TimerSettings *) timerForItem:(NSUInteger) row inComponent:(NSUInteger) component;

// save/delete timers
- (void) saveTimer:(TimerSettings *) timer withName:(NSString *)name;
- (void) deleteTimerAtIndexPath:(NSIndexPath *) indexPath inComponent:(NSUInteger) component;

// statics
+ (NSArray *) keys;
+ (BOOL) nameExists:(NSString *) name;

@end

#endif
