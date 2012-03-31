//
//  TimerSettings.m
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerSettings.h"

@implementation TimerSettings

@synthesize hours_, minutes_, seconds_, overtimePeriods_, overtimeMinutes_, overtimeSeconds_, type_;

- (NSDictionary *) toDictionary
{
    return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                  [NSNumber numberWithInt:hours_],
                                                  [NSNumber numberWithInt:minutes_],
                                                  [NSNumber numberWithInt:seconds_],
                                                  [NSNumber numberWithInt:overtimeMinutes_],
                                                  [NSNumber numberWithInt:overtimeSeconds_],
                                                  [NSNumber numberWithInt:overtimePeriods_],
                                                  [NSNumber numberWithInt:type_],
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
    hours_           = 0;
    minutes_         = 10;
    seconds_         = 0;
    overtimeMinutes_ = 0;
    overtimeSeconds_ = 30;
    overtimePeriods_ = 5;
    type_            = ByoYomi;

}

- (id) initWithHours:(unsigned)hours
             minutes:(unsigned)minutes
             seconds:(unsigned)seconds
     overtimeMinutes:(unsigned)overtimeMinutes
     overtimeSeconds:(unsigned)overtimeSeconds
             overtimePeriods:(unsigned)overtimePeriods
                type:(TimerType)type
{
    self = [super init];
    if (self) {
        hours_           = hours;
        minutes_         = minutes;
        seconds_         = seconds;
        overtimeMinutes_ = overtimeMinutes;
        overtimeSeconds_ = overtimeSeconds;
        overtimePeriods_ = overtimePeriods;
        type_            = type;
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

        hours_           = [[dict valueForKey:@"h"] intValue];
        minutes_         = [[dict valueForKey:@"m"] intValue];
        seconds_         = [[dict valueForKey:@"s"] intValue];
        overtimeMinutes_ = [[dict valueForKey:@"otm"] intValue];
        overtimeSeconds_ = [[dict valueForKey:@"ots"] intValue];
        overtimePeriods_ = [[dict valueForKey:@"otp"] intValue];
        type_            = (TimerType)       [[dict valueForKey:@"type"] intValue];
    }
    return self;
}


/**
 * Give a plain-text description of the timer settings.
 */
- (NSString *) description
{
    NSString * unpadded     = [TimerSettings StringForType:type_];
    NSMutableString * title = [NSMutableString stringWithFormat:@"%-12@",unpadded];
    
    // pretty print the main time
    if (hours_ == 0 && minutes_ == 0 && seconds_ == 0)
        [title appendString:@"No main time, "];
    else {

        if (hours_ > 0)
            [title appendFormat:@" %d hour", hours_];
        if (hours_ > 1)
            [title appendString:@"s"];

        if (minutes_ > 0)
            [title appendFormat:@" %d minute", minutes_];
        if (minutes_ > 1)
            [title appendFormat:@"s", minutes_];

        if (seconds_ > 0)
            [title appendFormat:@" %d second", seconds_];
        if (seconds_ > 1)
            [title appendFormat:@"s", seconds_];

        [title appendString:@" main time, "];
    }


    if (type_ == Absolute || type_ == Hourglass)
        return title;

    // for time settings with overtime, pretty print that data
    NSMutableString * ot = [NSMutableString stringWithString:@""];

    if (overtimeMinutes_ > 0)
        [ot appendFormat:@" %d minute", minutes_];
    if (overtimeMinutes_ > 1)
        [ot appendFormat:@"s", minutes_];

    if (overtimeSeconds_ > 0)
        [ot appendFormat:@" %d second", seconds_];
    if (overtimeSeconds_ > 1)
        [ot appendFormat:@"s", seconds_];

    if (type_ == ByoYomi) {
        [title appendFormat:@"%d periods with %@ each", overtimePeriods_, ot];
        return title;
    }

    if (type_ == Canadian) {
        [title appendFormat:@"%d moves in %@", overtimePeriods_, ot];
        return title;
    }

    // type is Fischer or Bronstein
    [title appendFormat:@"%@ per move"];

    return title;
}

- (BOOL) isEqual:(TimerSettings *) other
{
    return (type_    == other.type_    &&
            hours_   == other.hours_   &&
            minutes_ == other.minutes_ &&
            seconds_ == other.seconds_ &&
            overtimeMinutes_ == other.overtimeMinutes_ &&
            overtimeSeconds_ == other.overtimeSeconds_ &&
            overtimePeriods_ == other.overtimePeriods_
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
+ (TimerSettings *) TimerForType:(TimerType) type
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
        return [[TimerSettings alloc] initWithHours:0 minutes:1 seconds:0 overtimeMinutes:0 overtimeSeconds:0 overtimePeriods:0 type:type];

    return [[TimerSettings alloc] init];
}

@end
