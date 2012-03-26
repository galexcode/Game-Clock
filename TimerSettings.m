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
        hours_           = 0;
        minutes_         = 10;
        seconds_         = 0;
        overtimeMinutes_ = 0;
        overtimeSeconds_ = 30;
        overtimePeriods_ = 5;
        type_            = ByoYomi;
    }
    return self;
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


+ (NSArray *)TimerTypes
{
    static NSArray *data = nil;
    if (!data) {
        data = [NSArray arrayWithObjects:
                @"Absolute",
                @"Bronstein",
                @"Byoyomi",
                @"Canadian",
                @"Fischer",
                @"Hourglass",
                nil];
    }
    return data;
}

@end
