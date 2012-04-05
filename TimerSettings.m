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

#import "TimerSettings.h"
#import "ActivatedTimer.h"

@implementation TimerSettings

@synthesize hours, minutes, seconds, overtimePeriods, overtimeMinutes, overtimeSeconds, type;

- (NSDictionary *) toDictionary
{
    return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                  [NSNumber numberWithInt:hours],
                                                  [NSNumber numberWithInt:minutes],
                                                  [NSNumber numberWithInt:seconds],
                                                  [NSNumber numberWithInt:overtimeMinutes],
                                                  [NSNumber numberWithInt:overtimeSeconds],
                                                  [NSNumber numberWithInt:overtimePeriods],
                                                  [NSNumber numberWithInt:type],
                                                  nil]
                                         forKeys:[NSArray arrayWithObjects:
                                                  @"h",
                                                  @"m",
                                                  @"s",
                                                  @"otm",
                                                  @"ots",
                                                  @"otp",
                                                  @"type",
                                                  nil]
            ];
}

- (id) init
{
    self = [super init];
    if (self) {
        [self populateDefaults];
    }
    return self;
}

- (void) populateDefaults
{
    hours           = 0;
    minutes         = 10;
    seconds         = 0;
    overtimeMinutes = 0;
    overtimeSeconds = 30;
    overtimePeriods = 5;
    type            = ByoYomi;

}

- (id) initWithHours:(unsigned)_hours
             minutes:(unsigned)_minutes
             seconds:(unsigned)_seconds
     overtimeMinutes:(unsigned)_overtimeMinutes
     overtimeSeconds:(unsigned)_overtimeSeconds
             overtimePeriods:(unsigned)_overtimePeriods
                type:(TimerType)_type
{
    self = [super init];
    if (self) {
        hours           = _hours;
        minutes         = _minutes;
        seconds         = _seconds;
        overtimeMinutes = _overtimeMinutes;
        overtimeSeconds = _overtimeSeconds;
        overtimePeriods = _overtimePeriods;
        type            = _type;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *) dict
{
    self = [super init];
    if (self) {

        // don't choke on empty dictionaries
        if ([dict count] == 0) {
            [self populateDefaults];
            return self;
        }

        hours           = [[dict valueForKey:@"h"] intValue];
        minutes         = [[dict valueForKey:@"m"] intValue];
        seconds         = [[dict valueForKey:@"s"] intValue];
        overtimeMinutes = [[dict valueForKey:@"otm"] intValue];
        overtimeSeconds = [[dict valueForKey:@"ots"] intValue];
        overtimePeriods = [[dict valueForKey:@"otp"] intValue];
        type            = (TimerType) [[dict valueForKey:@"type"] intValue];
    }
    return self;
}

/**
 * Validate the timer settings.  Returns a null pointer if the timer is valid, otherwise the
 * string contains the reason the timer is not valid.
 */
- (NSString*) validateSettings
{
    NSString * typeStr = [TimerSettings StringForType:type];

    if (type == Absolute || type == Hourglass) {
        if (overtimeMinutes > 0 || overtimeSeconds > 0 || overtimePeriods > 0)
            return [NSString stringWithFormat:@"%@ timing cannot have overtime set.  Periods:%d, Minutes:%d, Seconds:%d",
                 typeStr, overtimePeriods, overtimeMinutes, overtimeSeconds];
        else if (hours == 0 && minutes == 0 && seconds == 0)
            return [NSString stringWithFormat:@"%@ timing must have a positive main time", typeStr];
        else
            return nil;
    }

    if (type == Fischer || type == Bronstein) {
        if (overtimeMinutes == 0 && overtimeSeconds == 0)
            return [NSString stringWithFormat:@"%@ timing must have a positive overtime minutes/seconds", typeStr];
        else if (hours == 0 && minutes == 0 && seconds == 0)
            return [NSString stringWithFormat:@"%@ timing must have a positive main time", typeStr];
        else
            return nil;
    }

    if (type == ByoYomi || type == Canadian) {
        if (overtimeMinutes == 0 && overtimeSeconds == 0)
            return [NSString stringWithFormat:@"%@ timing must have a positive overtime minutes/seconds", typeStr];
        else if (overtimePeriods == 0)
            return [NSString stringWithFormat:@"%@ timing must have a positive number of overtime periods", typeStr];
        else
            return nil;
    }

    return @"Unknown type — Crap Pants!";
}


/**
 * Returns settings with the irrelevant bits removed.  Used for saving, launching, comparing, etc.
 */
- (TimerSettings *) effectiveSettings
{
    TimerSettings * newCopy = [[TimerSettings alloc] initWithDictionary:[self toDictionary]];
    
    if (type == Absolute || type == Hourglass) {
        overtimeMinutes = 0;
        overtimeSeconds = 0;
        overtimePeriods = 0;
    }
    else if (type == Bronstein || type == Fischer) {
        overtimePeriods = 0;
    }
    
    return newCopy;
}


/**
 * Give a plain-text description of the timer settings.
 */
- (NSString *) description
{
    NSString * unpadded     = [TimerSettings StringForType:type];
    NSMutableString * title = [NSMutableString stringWithString:unpadded];
    
    [title appendString:@" "];
    
    // pretty print the main time
    if (hours == 0 && minutes == 0 && seconds == 0)
        [title appendString:@"0"];
    else {
        if (hours > 0)
            [title appendFormat:@"%02d:", hours];
        if (minutes > 1)
            [title appendFormat:@"%02d:", minutes];

        [title appendFormat:@"%02d", seconds];
    }

    // These only have main time
    if (type == Absolute || type == Hourglass)
        return title;

    [title appendString:@" + "];


    // for time settings with overtime, pretty print that data
    if (type == Canadian || type == ByoYomi)
        [title appendFormat:@"%d × ", overtimePeriods];
    
    if (overtimeMinutes > 0)
        [title appendFormat:@"%02d:", overtimeMinutes];
    
    [title appendFormat:@"%02d", overtimeSeconds];

    if (type == Fischer || type == Bronstein)
        [title appendString:@"/move:"];

    return title;
}

- (BOOL) isEqual:(TimerSettings *) other
{
    return (type    == other.type    &&
            hours   == other.hours   &&
            minutes == other.minutes &&
            seconds == other.seconds &&
            overtimeMinutes == other.overtimeMinutes &&
            overtimeSeconds == other.overtimeSeconds &&
            overtimePeriods == other.overtimePeriods
            );
}


/**
 * Converts an enum element into a string
 */
#define FROM_LITERAL(x) \
    if (type == x) return @#x;
+ (NSString *) StringForType:(TimerType) type
{
    FROM_LITERAL(Absolute)
    FROM_LITERAL(Bronstein)
    FROM_LITERAL(ByoYomi)
    FROM_LITERAL(Canadian)
    FROM_LITERAL(Fischer)
    FROM_LITERAL(Hourglass)
    return @"";
}
#undef FROM_LITERAL


/**
 * Returns an array of strings for elements of the TimerType enum
 */
+ (NSArray *)TimerTypes
{
    static NSArray *data = nil;
    if (!data) {
        data = [NSArray arrayWithObjects:
                @"Absolute",
                @"Bronstein",
                @"ByoYomi",
                @"Canadian",
                @"Fischer",
                @"Hourglass",
                nil];
    }
    return data;
    NSString * junk;
    NSUInteger index = [data indexOfObject:junk];
    index += 1;
}


/**
 * Returns the index of the specified type in the array returned by
 * [TimerSettings TimerTypes]
 */
+ (NSUInteger) IndexForType:(TimerType) type
{
    NSString * string = [TimerSettings StringForType:type];
    NSUInteger index  = [[TimerSettings TimerTypes] indexOfObject:string];
    return index;
}


/**
 * Default timers for each type
 */
+ (TimerSettings *) DefaultTimerForType:(TimerType) type
{
    if (type == Absolute)
        return [[TimerSettings alloc] initWithHours:0 minutes:15 seconds:0 overtimeMinutes:0 overtimeSeconds:0 overtimePeriods:0 type:type];

    if (type == Bronstein ||
        type == Fischer)
        return [[TimerSettings alloc] initWithHours:0 minutes:15 seconds:0 overtimeMinutes:0 overtimeSeconds:10 overtimePeriods:0 type:type];

    if (type == ByoYomi)
        return [[TimerSettings alloc] initWithHours:0 minutes:15 seconds:0 overtimeMinutes:0 overtimeSeconds:30 overtimePeriods:3 type:type];

    // main time 5 minutes, with 3 minute overtime periods of 10 moves each.
    if (type == Canadian)
    return [[TimerSettings alloc] initWithHours:0 minutes:5 seconds:0 overtimeMinutes:3 overtimeSeconds:0 overtimePeriods:10 type:type];

    if (type == Hourglass)
        return [[TimerSettings alloc] initWithHours:0 minutes:4 seconds:0 overtimeMinutes:0 overtimeSeconds:0 overtimePeriods:0 type:type];

    return [[TimerSettings alloc] init];
}

@end
