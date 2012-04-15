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

#import "TimerSettings.h"
#import "ActivatedTimer.h"
#import "AppDelegate.h"

@implementation TimerSettings

@synthesize hours, minutes, seconds, overtimePeriods, overtimeMinutes, overtimeSeconds, type;

/**
 * Serialization method
 */
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


/**
 * Deserialization constructor
 */
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
    static NSString * separator = nil;
    if (!separator)
        separator = [AppDelegate timeComponentSeparator];
    
    NSString * unpadded     = [TimerSettings StringForType:type];
    NSMutableString * title = [NSMutableString stringWithString:unpadded];

    [title appendString:@" "];

    // pretty print the main time
    if (hours == 0 && minutes == 0 && seconds == 0)
        [title appendString:@"0:00"];
    else if (hours == 0)
        [title appendFormat:@"%d%@%02d", minutes, separator, seconds];
    else
        [title appendFormat:@"%d%@%02d%@%02d", hours, separator, minutes, separator, seconds];

    // These only have main time
    if (type == Absolute || type == Hourglass)
        return title;

    [title appendString:@" + "];

    // for time settings with overtime, pretty print that data
    if (type == Canadian || type == ByoYomi)
        [title appendFormat:@"%d × ", overtimePeriods];


    [title appendFormat:@"%d%@%02d", overtimeMinutes, separator, overtimeSeconds];

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
