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

#import "TimerSupply.h"
#import "TimerSettings.h"
#import "MainWindowViewController.h"
#import "AppDelegate.h"

/**
 * Furnishes a collection of timers with categories to the large lower table
 * in the main view.  Encapsulates access to the prefs item "Timers".
 */
@implementation TimerSupply

-(id)init:(MainWindowViewController *) _mwvc delegate:(AppDelegate *) _delegate
{
    if (self = [super init])
    {
        toBeConfirmedSaveName = nil;
        delegate = _delegate;
        mwvc  = _mwvc;
        prefs = [NSUserDefaults standardUserDefaults];
        
        // load preset timers
        
        NSDictionary * timersFromPrefs = [prefs dictionaryForKey:@"Timers"];
        NSArray * keys  = [timersFromPrefs allKeys];
        
        if ([keys count] == 0)
            [self createInitialObjects];
        else
            [self createTimersFromDictionary:timersFromPrefs];
        
        
    }
    return self;
}

- (void) createTimersFromDictionary:(NSDictionary *) dict
{
    if (timers)
        return;
    
    // insert into mutable dictionary, and then transfer to timers
    NSMutableDictionary * theTimers = [[NSMutableDictionary alloc] initWithCapacity:[[dict allKeys] count]];

    for (NSString *class in dict)
    {
        
        if ([class isEqualToString:@"Paused"]) {
            // TODO: recover paused games
        }
        else {
            // recover stored timers (History/Builtin/Favorites/Saved)
            NSDictionary * nameAndTimers = [dict objectForKey:class];
            NSMutableDictionary * toAdd  = [[NSMutableDictionary alloc] initWithCapacity:[nameAndTimers count]];
            
            if ([class isEqualToString:@"History"]) {
                for (NSDate * date in nameAndTimers)
                {
                    NSString * timerName     = [[nameAndTimers objectForKey:date] objectForKey:@"Name"];
                    NSDictionary * timerDict = [[nameAndTimers objectForKey:date] objectForKey:@"Timer"];
                    TimerSettings * theTimer = [[TimerSettings alloc] initWithDictionary:timerDict];
                    [toAdd setObject:theTimer forKey:timerName];
                }   
            }
            else {
                // convert each dictionary to a timer and add it to 'timers'
                for (NSString * name in nameAndTimers)
                {
                    TimerSettings * theTimer = [[TimerSettings alloc] initWithDictionary:[nameAndTimers objectForKey:name]];
                    [toAdd setObject:theTimer forKey:name];
                }
            }
            [theTimers setObject:[NSDictionary dictionaryWithDictionary:toAdd]
                          forKey:class];
        }
    }
    
    timers = [[NSDictionary alloc] initWithDictionary:theTimers];
}


/**
 * Return names for the three sets of timers selectable in the main view
 */
+ (NSArray *) keys
{
	static NSArray * keys = nil;
    if (!keys) 
    {
        keys = [NSArray arrayWithObjects:@"Builtins",
                @"Favorites",
                @"History",
                @"Saved",
                @"Paused",
                nil];
    }
    
	return keys;
}


/**
 * Helper for the UITableView showing Builtin/Favorites/History
 */
- (NSUInteger) rowsInComponent:(NSUInteger) component
{
    // use [TimerSupply keys] to maintain correct order
    NSString * key       = [[TimerSupply keys] objectAtIndex:component];
    NSDictionary * nAndT = [timers objectForKey:key];
    return [nAndT count];
}

/**
 * Helper for the UITableView showing Builtin/Favorites/History
 */
- (NSString *) titleForItem:(NSUInteger) row inComponent:(NSUInteger) component
{
    NSString * key       = [[TimerSupply keys] objectAtIndex:component];
    NSDictionary * nAndT = [timers objectForKey:key];
    NSArray * types      = [nAndT allKeys];
    
    if (component == HISTORY_TIMERS_INDEX)
        return [[types objectAtIndex:row] objectForKey:@"Name"];
    return [types objectAtIndex:row];
}

/**
 * Inverse of titleForItem:inComponent
 */
- (NSArray *) indexForItem:(NSString *) description inCollection:(NSString *) collection
{
    NSDictionary * timerCollection = [timers objectForKey:collection];
    NSNumber * i = [NSNumber numberWithUnsignedInt:[[TimerSupply keys] indexOfObject:collection]];
    NSNumber * j = [NSNumber numberWithUnsignedInt:[[timerCollection allKeys] indexOfObject:description]];
    return [NSArray arrayWithObjects:i, j, nil];
}

- (TimerSettings *) timerForItem:(NSUInteger) row inComponent:(NSUInteger) component
{
    NSString * key       = [[TimerSupply keys] objectAtIndex:component];
    NSDictionary * nAndT = [timers objectForKey:key];
    NSArray * types      = [nAndT allKeys];
    
    TimerSettings * sel  = nil;
    if (component == HISTORY_TIMERS_INDEX) {
        NSDate * date = [types objectAtIndex:row];
        sel = [[nAndT objectForKey:date] objectForKey:@"Timer"];
    }
    else {
        NSString * timerKey = [types objectAtIndex:row];
        sel = [nAndT objectForKey:timerKey];
    }
    
    
    return [[TimerSettings alloc] initWithDictionary:[sel toDictionary]];
}


/**
 * Called on the app's first run time to create initial prefs
 */
- (void) createInitialObjects
{
    
    // create default timers
    TimerSettings * byoyomi30x5  = [[TimerSettings alloc] init];
    TimerSettings * by3x10blitz  = [[TimerSettings alloc] initWithHours:0
                                                                minutes:0
                                                                seconds:0
                                                        overtimeMinutes:0
                                                        overtimeSeconds:10
                                                        overtimePeriods:3
                                                                   type:ByoYomi];
    TimerSettings * fischer15x10 = [[TimerSettings alloc] initWithHours:0
                                                                minutes:15
                                                                seconds:0
                                                        overtimeMinutes:0
                                                        overtimeSeconds:10
                                                        overtimePeriods:0
                                                                   type:Fischer];
    TimerSettings * blitz15      = [[TimerSettings alloc] initWithHours:0
                                                                minutes:15
                                                                seconds:0
                                                        overtimeMinutes:0
                                                        overtimeSeconds:0
                                                        overtimePeriods:0
                                                                   type:Absolute];
    TimerSettings * blitz10      = [[TimerSettings alloc] initWithHours:0
                                                                minutes:10
                                                                seconds:0
                                                        overtimeMinutes:0
                                                        overtimeSeconds:0
                                                        overtimePeriods:0
                                                                   type:Absolute];
    
    // aggregate them in an array
    NSDictionary * builtins = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                              [by3x10blitz  toDictionary],
                                                              [byoyomi30x5  toDictionary],
                                                              [fischer15x10 toDictionary],
                                                              [blitz15      toDictionary],
                                                              [blitz10      toDictionary],
                                                              nil]
                                                     forKeys:[NSArray arrayWithObjects:
                                                              @"Byoyomi 10 second blitz",
                                                              @"Byoyomi 10 minutes + 5x30 seconds",
                                                              @"Fischer 15 minutes main + 10 seconds per move",
                                                              @"Absolute 15 minutes",
                                                              @"Absolute 10 minutes",
                                                              nil]];
    
    // create 'Timers' preference entry
    NSDictionary * theTimers = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                    builtins,
                                                                    [NSDictionary dictionary],
                                                                    [NSDictionary dictionary],
                                                                    [NSDictionary dictionary],
                                                                    [NSDictionary dictionary],
                                                                    nil]
                                                           forKeys:[NSArray arrayWithObjects:
                                                                    @"Builtins",
                                                                    @"Favorites",
                                                                    @"History",
                                                                    @"Saved",
                                                                    @"Paused",
                                                                    nil]];
    
    // store in prefs
    [prefs setObject:theTimers forKey:@"Timers"];
    [prefs synchronize];
    
    // create TimerSetting objects
    [self createTimersFromDictionary:theTimers];
}


/**
 * Handle save alert button clicks
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // cancel button
    if (buttonIndex == 0)
        return;
    
    NSString * newName = nil;
    
    // save dialogue
    if ([[alertView title] isEqualToString:@"Save"]) {
        NSString * saveName = [[alertView textFieldAtIndex:0] text]; 
        
        NSLog(@"clicked button %d => %@", buttonIndex, saveName);
        
        // timer with that name exists, ask if confirmed to overwrite
        if ([TimerSupply nameExists:saveName]) {
            // alert to user
            NSString * explanation = [NSString stringWithFormat:@"A timer with the name %@ exists, do you wish to overwrite?", saveName];
            UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:saveName
                                                              message:explanation
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Overwrite",nil];
            
            [confirm show];
            toBeConfirmedSaveName = [[NSString alloc] initWithString:saveName];
            return;
        }
        newName = [saveName copy];
    }
    else // the confirmation dialogue
        newName = toBeConfirmedSaveName;
    
    // Either the user clicked yes in the confirm dialogue (launched above), or entered
    // a nonexistant name
    [self saveTimer:[delegate settings] withName:newName];
    
    // rewrite all fields with the new settings
    [mwvc updateInterfaceAccordingToStoredSettings];

    // update save button status, select row, etc.
    [mwvc alterTimerSettingsAccordingToUI];
    toBeConfirmedSaveName = nil;
    
}

+ (BOOL) nameExists:(NSString *) name
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary * timersFromPrefs = [prefs dictionaryForKey:@"Timers"];
    NSArray * keys  = [timersFromPrefs allKeys];
    
    for (NSString * key in keys) {
        // consider each timer collection
        NSDictionary * timerCollection = [timersFromPrefs objectForKey:key];
        if ([timerCollection count] == 0)
            continue;
        
        for (NSString * description in [timerCollection allKeys]) {
            if ([description isEqualToString:name])
                return YES;
        }
    }
    return NO;
}


- (void) saveTimer:(TimerSettings *) timer withName:(NSString *)name
{
    NSMutableDictionary * timersFromPrefs = [[prefs dictionaryForKey:@"Timers"] mutableCopy];
    NSMutableDictionary * savedTimers     = [[timersFromPrefs objectForKey:@"Saved"] mutableCopy];
    
    // store item
    [savedTimers setValue:[timer toDictionary] forKey:name];
    [timersFromPrefs setObject:savedTimers forKey:@"Saved"];
    
    // store prefs
    [prefs setObject:timersFromPrefs forKey:@"Timers"];
    [prefs synchronize];
    
    // update data
    timers = nil;
    [self createTimersFromDictionary:timersFromPrefs];
    [mwvc updateInterfaceAccordingToStoredSettings];
}

- (void) deleteTimerAtIndexPath:(NSIndexPath *) indexPath inComponent:(NSUInteger) component
{
    NSMutableDictionary * timersFromPrefs = [[prefs dictionaryForKey:@"Timers"] mutableCopy];
    NSMutableDictionary * savedTimers     = [[timersFromPrefs objectForKey:@"Saved"] mutableCopy];
    
    unsigned row    = [indexPath indexAtPosition:1];
    NSString * name = [self titleForItem:row inComponent:component];
    
    // remove item
    [savedTimers removeObjectForKey:name];
    [timersFromPrefs setObject:savedTimers forKey:@"Saved"];
    
    // update prefs
    [prefs setObject:timersFromPrefs forKey:@"Timers"];
    [prefs synchronize];
    
    // update data
    timers = nil;
    [self createTimersFromDictionary:timersFromPrefs];
    [mwvc updateInterfaceAccordingToStoredSettings];
}

- (void) addHistoryTimer:(TimerSettings *) timer
{
    NSMutableDictionary * timersFromPrefs = [[prefs dictionaryForKey:@"Timers"] mutableCopy];
    NSMutableDictionary * savedTimers     = [[timersFromPrefs objectForKey:@"History"] mutableCopy];

    NSDictionary * timerDict = [timer toDictionary];
    
    // remove the item if it exists in history
    for (NSDate * date in [savedTimers allKeys]) {
        NSDictionary * nameAndTimer = [savedTimers objectForKey:date];
        if ([[nameAndTimer objectForKey:@"Timer"] isEqualToDictionary:timerDict]) {
            [savedTimers removeObjectForKey:date];
            break;
        }
    }
    
    // add item to history
    NSMutableDictionary * toStore = [[NSMutableDictionary alloc] initWithCapacity:2];
    [toStore setObject:[timer description] forKey:@"Name"];
    [toStore setObject:timerDict forKey:@"Timer"];
    [savedTimers setObject:toStore forKey:[NSDate date]];
    [timersFromPrefs setObject:savedTimers forKey:@"History"];
    
    // update prefs
    [prefs setObject:timersFromPrefs forKey:@"Timers"];
    [prefs synchronize];
    
    // update data
    timers = nil;
    [self createTimersFromDictionary:timersFromPrefs];
    [mwvc updateInterfaceAccordingToStoredSettings];
}


@end
