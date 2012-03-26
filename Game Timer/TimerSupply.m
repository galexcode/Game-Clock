//
//  TimerSupply.m
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
        categoryChoices = [NSArray arrayWithObjects:
                           @"History", 
                           @"Favorites",
                           @"Junk",
                           nil];        
    }
    return self;
}

- (NSString *) titleForCategory:(NSUInteger) row
{
    return @"";
}

- (NSString *) titleForItem:(NSUInteger) row inCategory:(NSUInteger) category
{
    return @"";
}


/**
 * Called on the app's first run time to create initial prefs
 */
- (void) createInitialObjects
{

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
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
    NSDictionary * timers = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                 builtins, 
                                                                 [NSArray array],
                                                                 nil]
                                                        forKeys:[NSArray arrayWithObjects:
                                                                 @"Builtins",
                                                                 @"History",
                                                                 nil]];
    
    [prefs setObject:timers forKey:@"Timers"];
    
    
    [prefs synchronize];
}


@end
