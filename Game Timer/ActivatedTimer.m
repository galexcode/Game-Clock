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

#import "ActivatedTimer.h"
#import "AppDelegate.h"

@implementation ActivatedTimer

@synthesize startingPlayer, whoseTurn, type;
@synthesize whiteTime, blackTime;
@synthesize hasExpired;

- (id) init:(TimerSettings *) _settings firstPlayer:(Player) player
{
    self = [super init];
    if (self) {

        // Connect the application's AppDelegate instance
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        // initialize members
        settings   = _settings;
        hasExpired = NO;

        unsigned mainSeconds = ([settings hours] * 60 + [settings minutes]) * 60 + [settings seconds];
        unsigned otSeconds   = [settings overtimeMinutes] * 60 + [settings overtimeSeconds];

        whiteTime.moves           = 0;
        whiteTime.mainSeconds     = mainSeconds;
        whiteTime.periods         = [settings overtimePeriods];
        whiteTime.overtimeSeconds = otSeconds;
        blackTime.moves           = 0;
        blackTime.mainSeconds     = mainSeconds;
        blackTime.periods         = [settings overtimePeriods];
        blackTime.overtimeSeconds = otSeconds;

        whoseTurn = startingPlayer
            = player;
        type      = [settings type];
        ticker    = nil;
    }
    return self;
}

// simplify our lives using X macros
#define VAR_TABLE \
    X(whiteTime.moves           , wm)  \
X(whiteTime.mainSeconds     , wms) \
X(whiteTime.periods         , wp)  \
X(whiteTime.overtimeSeconds , wos) \
X(blackTime.moves           , bm)  \
X(blackTime.mainSeconds     , bms) \
X(blackTime.periods         , bp)  \
X(blackTime.overtimeSeconds , bos) \
Y(type                      , TimerType , type) \
Y(whoseTurn                 , Player    , turn) \
Y(startingPlayer            , Player    , start)

#define X(a,b) \
    a = [[dict valueForKey:@#b] intValue];

#define Y(a,b,c) \
    a = (b) [[dict valueForKey:@#c] intValue];

- (id) init:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        VAR_TABLE
            /*
               whiteMoves           = [[dict valueForKey:@"wm"]               intValue];
               whiteMainSeconds     = [[dict valueForKey:@"wms"]              intValue];
               whitePeriods         = [[dict valueForKey:@"wp"]               intValue];
               whiteOvertimeSeconds = [[dict valueForKey:@"wos"]              intValue];
               blackMoves           = [[dict valueForKey:@"bm"]               intValue];
               blackMainSeconds     = [[dict valueForKey:@"bms"]              intValue];
               blackPeriods         = [[dict valueForKey:@"bp"]               intValue];
               blackOvertimeSeconds = [[dict valueForKey:@"bos"]              intValue];
               type                 = (TimerType) [[dict valueForKey:@"type"] intValue];
               whoseTurn            = (Player)    [[dict valueForKey:@"turn"]    intValue];
               startingPlayer       = (Player)    [[dict valueForKey:@"start"]   intValue];
               */
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
    VAR_TABLE

        return [NSDictionary dictionaryWithDictionary:dict];

    /*
       return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                            [NSNumber numberWithInt:whiteMoves],
                            [NSNumber numberWithInt:whiteMainSeconds],
                            [NSNumber numberWithInt:whitePeriods],
                            [NSNumber numberWithInt:whiteOvertimeSeconds],
                            [NSNumber numberWithInt:blackMoves],
                            [NSNumber numberWithInt:blackMainSeconds],
                            [NSNumber numberWithInt:blackPeriods],
                            [NSNumber numberWithInt:blackOvertimeSeconds],
                            [NSNumber numberWithInt:type],
                            [NSNumber numberWithInt:whoseTurn],
                            [NSNumber numberWithInt:startingPlayer],
                            nil]
forKeys:[NSArray arrayWithObjects:
@"wm",
@"wms",
@"wp",
@"wos",
@"bm",
@"bms",
@"bp",
@"bos",
@"type",
@"turn",
@"start",
nil]];
*/
}
#undef X
#undef Y

- (BOOL) isActive
{
    return [ticker isValid];
}

- (void) activate
{
    if (ticker && [ticker isValid])
        return;

    // start the ticker
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];
}


#define CASE(x) \
    case x: \
hasExpired = [self decrement##x:data]; \
break;
#define SCASE(x) \
    case x: \
hasExpired = [ActivatedTimer decrement##x:data]; \
break;
#define OCASE(x) \
    case x: \
hasExpired = [self decrement##x:data notMoving:other]; \
break;

- (void) tick:(NSTimer*)timer
{
    Player toMove    = whoseTurn;
    TimeData * data  = nil;
    TimeData * other = nil;

    if (toMove == Black) {
        data  = &blackTime;
        other = &whiteTime;
    }
    else {
        data  = &whiteTime;
        other = &blackTime;
    }

    // decrement the timer and set hasExpired
    switch ([settings type]) {
        SCASE(Absolute);
        SCASE(Bronstein);
        SCASE(Fischer);
        CASE(ByoYomi);
        CASE(Canadian);
        OCASE(Hourglass);
    }


}

#undef CASE
#undef OCASE
#undef SCASE

- (void) deactivate
{
    [ticker invalidate];
    ticker = nil;
}

// Decrements the timer, returning YES if time has expired
+ (BOOL) decrementAbsolute:(TimeData *) data
{
    if (data->mainSeconds == 0)
        return YES;

    data->mainSeconds--;
    return NO;
}

+ (BOOL) decrementBronstein:(TimeData *) data
{
    return [ActivatedTimer decrementAbsolute:data];
}

+ (BOOL) decrementFischer:(TimeData *) data
{
    return [ActivatedTimer decrementAbsolute:data];
}

- (BOOL) decrementByoYomi:(TimeData *) data
{
    // main time has not expired
    if (![ActivatedTimer decrementAbsolute:data])
        return NO;

    // overtime period time has not expired
    if (data->overtimeSeconds > 0) {
        data->overtimeSeconds--;
        return NO;
    }

    // maintime == overtime == periods == 0 => time is up
    if (data->periods == 0)
        return YES;

    data->periods--;
    data->overtimeSeconds = [settings overtimeMinutes] * 60 + [settings overtimeSeconds];
    return NO;
}

- (BOOL) decrementCanadian:(TimeData *) data
{
    // main time has not expired
    if (![ActivatedTimer decrementAbsolute:data])
        return NO;

    // overtime period time has not expired
    if (data->overtimeSeconds > 0) {
        data->overtimeSeconds--;
        return NO;
    }

    return YES;
}

- (BOOL) decrementHourglass:(TimeData *) one notMoving:(TimeData*) two
{
    if (one->mainSeconds == 0)
        return YES;

    one->mainSeconds--;
    two->mainSeconds++;
    return NO;
}

@end
