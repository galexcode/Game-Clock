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

#import "ActivatedTimer.h"
#import "AppDelegate.h"

@implementation ActivatedTimer

@synthesize startingPlayer, whoseTurn, type;
@synthesize whiteTime, blackTime;
@synthesize hasExpired, timerID;
@synthesize atvc;

- (id) init:(TimerSettings *) _settings firstPlayer:(Player) player
{
    self = [super init];
    if (self) {

        // Connect the application's AppDelegate instance
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        [self zeroSettings];

        // initialize members
        settings   = _settings;

        unsigned mainDeciseconds = (([settings hours] * 60 + [settings minutes]) * 60 + [settings seconds]) * 10;
        unsigned otDeciseconds   = ([settings overtimeMinutes] * 60 + [settings overtimeSeconds]) * 10;

        whiteTime.moves               = 0;
        whiteTime.mainDeciseconds     = mainDeciseconds;
        whiteTime.periods             = [settings overtimePeriods];
        whiteTime.overtimeDeciseconds = otDeciseconds;
        blackTime.moves               = 0;
        blackTime.mainDeciseconds     = mainDeciseconds;
        blackTime.periods             = [settings overtimePeriods];
        blackTime.overtimeDeciseconds = otDeciseconds;

        whoseTurn = startingPlayer = player;
        type      = [settings type];

        // make a unique id for storing paused timers
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        timerID = [[prefs valueForKey:@"Timer ID"] unsignedIntValue];
        timerID++;
        [prefs setValue:[NSNumber numberWithUnsignedInt:timerID] forKey:@"Timer ID"];
    }
    return self;
}

- (void) zeroSettings
{
    whiteTime.moves               = 0;
    whiteTime.mainDeciseconds     = 0;
    whiteTime.periods             = 0;
    whiteTime.overtimeDeciseconds = 0;
    blackTime.moves               = 0;
    blackTime.mainDeciseconds     = 0;
    blackTime.periods             = 0;
    blackTime.overtimeDeciseconds = 0;

    hasExpired = NO;
    atvc       = nil;
}

// simplify our lives using X macros
#define VAR_TABLE \
\
X(whiteTime.moves               , wm)  \
X(whiteTime.mainDeciseconds     , wms) \
X(whiteTime.periods             , wp)  \
X(whiteTime.overtimeDeciseconds , wos) \
X(blackTime.moves               , bm)  \
X(blackTime.mainDeciseconds     , bms) \
X(blackTime.periods             , bp)  \
X(blackTime.overtimeDeciseconds , bos) \
X(timerID                       , id) \
Y(type                          , TimerType , type) \
Y(whoseTurn                     , Player    , turn) \
Y(startingPlayer                , Player    , start)

#define X(a,b) \
    a = [[dict valueForKey:@#b] intValue];

// cast to type
#define Y(a,b,c) \
    a = (b) [[dict valueForKey:@#c] intValue];

- (id) init:(NSDictionary *) dict
{
    self = [super init];
    if (self) {

        [self zeroSettings];

        VAR_TABLE;

        if (type == ByoYomi) {
            blackTime.mainDeciseconds = 0;
            whiteTime.mainDeciseconds = 0;
        }

        timeExpendedThisTurn = 0;
    }
    return self;
}

// remove annoying compiler warnings
#undef X
#undef Y

#define X(a,b) \
    [dict setValue:[NSNumber numberWithInt:a] forKey:@#b];

#define Y(a,b,c) X(a,c)

- (NSDictionary *) toDictionary
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    VAR_TABLE;

    return [NSDictionary dictionaryWithDictionary:dict];
}
#undef X
#undef Y



#define CASE(x) \
    case x: \
hasExpired = [self decrement##x:data]; \
break;

#define OCASE(x) \
    case x: \
hasExpired = [self decrement##x:data notMoving:other]; \
break;


/**
 * Update state
 */
- (void) tick
{
    TimeData * data  = nil;
    TimeData * other = nil;

    if (whoseTurn == Black) {
        data  = &blackTime;
        other = &whiteTime;
    }
    else {
        data  = &whiteTime;
        other = &blackTime;
    }

    // decrement the timer and set hasExpired
    switch ([settings type]) {
        CASE(Absolute);
        CASE(Bronstein);
        CASE(Fischer);
        CASE(ByoYomi);
        CASE(Canadian);
        OCASE(Hourglass);
    }

    timeExpendedThisTurn++;
}

#undef CASE
#undef OCASE


- (void) swapPlayer
{
    TimeData * data = nil;
    if (whoseTurn == Black) {
        whoseTurn = White;
        data      = &blackTime;
    }
    else {
        whoseTurn = Black;
        data      = &whiteTime;
    }

    NSUInteger otds = data->overtimeDeciseconds;

    if (type == Fischer) {
        // increase time for player who moved
        data->mainDeciseconds += otds;
    }
    else if (type == Bronstein) {
        // increase time for player who moved
        data->mainDeciseconds += MIN(timeExpendedThisTurn, otds);
    }
    else if (type == ByoYomi) {
        if (data->mainDeciseconds == 0)
            data->overtimeDeciseconds = settings.overtimeMinutes * 600 + settings.overtimeSeconds * 10;
    }
    else if (type == Canadian) {
        data->periods--;
        if (data->periods == 0) {
            // player finished required moves in allotted time
            data->overtimeDeciseconds = settings.overtimeMinutes * 600 + settings.overtimeSeconds * 10;
            data->periods = settings.overtimePeriods;
        }
    }

    timeExpendedThisTurn = 0;

}

// Decrements the timer, returning YES if time has expired
- (BOOL) decrementAbsolute:(TimeData *) data
{
    if (data->mainDeciseconds == 0)
        return YES;

    data->mainDeciseconds--;
    return NO;
}

- (BOOL) decrementBronstein:(TimeData *) data
{
    return [self decrementAbsolute:data];
}

- (BOOL) decrementFischer:(TimeData *) data
{
    return [self decrementAbsolute:data];
}

- (BOOL) decrementByoYomi:(TimeData *) data
{
    // main time has not expired
    if (![self decrementAbsolute:data])
        return NO;

    // overtime period time has not expired
    if (data->overtimeDeciseconds > 0) {
        data->overtimeDeciseconds--;
        return NO;
    }

    // maintime == overtime == periods == 0 => time is up
    if (data->periods == 0)
        return YES;

    data->periods--;
    data->overtimeDeciseconds = [settings overtimeMinutes] * 600 + [settings overtimeSeconds] * 10;
    data->overtimeDeciseconds--;
    return NO;
}

- (BOOL) decrementCanadian:(TimeData *) data
{
    // main time has not expired
    if (![self decrementAbsolute:data])
        return NO;

    // overtime period time has not expired
    if (data->overtimeDeciseconds > 0) {
        data->overtimeDeciseconds--;
        return NO;
    }

    return YES;
}

- (BOOL) decrementHourglass:(TimeData *) one notMoving:(TimeData*) two
{
    if (one->mainDeciseconds == 0)
        return YES;

    one->mainDeciseconds--;
    two->mainDeciseconds++;
    return NO;
}

- (NSString *) description
{
    return [settings description];
}

@end
