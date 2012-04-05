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

#import "TimerSupply.h"
#import "TimerSettings.h"
#import "MainWindowViewController.h"
#import "AppDelegate.h"

/**
 * Furnishes a collection of timers with categories to the large lower table
 * in the main view
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
            // recover paused games
        }
        else {
            // recover stored timers (History/Builtin/Favorites/Saved)
            NSDictionary * nameAndTimers = [dict objectForKey:class];
            NSMutableDictionary * toAdd  = [[NSMutableDictionary alloc] initWithCapacity:[nameAndTimers count]];
            
            // convert each dictionary to a timer and add it to 'timers'
            for (NSString * name in nameAndTimers)
            {
                TimerSettings * theTimer = [[TimerSettings alloc] initWithDictionary:[nameAndTimers objectForKey:name]];
                [toAdd setObject:theTimer forKey:name];
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
    NSString * timerKey  = [types objectAtIndex:row];
    TimerSettings * selec = [nAndT objectForKey:timerKey];
    
    return [[TimerSettings alloc] initWithDictionary:[selec toDictionary]];
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
    [mwvc populateSettings:[delegate settings]];
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

// TODO: make it work correctly
- (void) saveTimer:(TimerSettings *) timer withName:(NSString *)name
{
    NSDictionary * timersFromPrefs    = [prefs dictionaryForKey:@"Timers"];
    NSMutableDictionary * savedTimers = [[timersFromPrefs objectForKey:@"Saved"] mutableCopy];

    [savedTimers setValue:[timer toDictionary] forKey:name];
    [prefs setObject:timersFromPrefs forKey:@"Timers"];
    [prefs synchronize];
    
    timers = nil;
    [self createTimersFromDictionary:timersFromPrefs];
}


@end
