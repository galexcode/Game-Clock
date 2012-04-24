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

#ifndef TimerSupply_h_included
#define TimerSupply_h_included

#import <Foundation/Foundation.h>
@class TimerSettings;
@class MainWindowViewController;
@class AppDelegate;
@class ActivatedTimer;

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
- (void) addHistoryTimer:(ActivatedTimer *) timer;

// statics
+ (NSArray *) keys;
+ (BOOL) nameExists:(NSString *) name;

@end

#endif
