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

/**
 * Furnishes a collection of timers with categories to the large lower table
 * in the main view
 */
@implementation TimerSupply

-(id)init
{
    if (self = [super init])
    {
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
            // recover stored timers (History/Builtin/Favorites)
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
    NSString * key        = [[TimerSupply keys] objectAtIndex:component];
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

- (TimerSettings *) timerForItem:(NSUInteger) row inComponent:(NSUInteger) component
{
    NSString * key       = [[TimerSupply keys] objectAtIndex:component];
    NSDictionary * nAndT = [timers objectForKey:key];
    NSArray * types      = [nAndT allKeys];
    return [timers objectForKey:[types objectAtIndex:row]];
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
    NSArray * builtins = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
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
                                                                    [NSArray array],
                                                                    [NSArray array],
                                                                    [NSArray array],
                                                                    nil]
                                                           forKeys:[NSArray arrayWithObjects:
                                                                    @"Builtins",
                                                                    @"Favorites",
                                                                    @"History",
                                                                    @"Paused",
                                                                    nil]];
    
    // store in prefs
    [prefs setObject:theTimers forKey:@"Timers"];
    [prefs synchronize];
    
    // create TimerSetting objects
    [self createTimersFromDictionary:theTimers];
}


@end
