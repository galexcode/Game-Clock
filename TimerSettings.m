//
//  TimerSettings.m
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerSettings.h"

@implementation TimerSettings

@synthesize hours, minutes, seconds, periods, overtimeMinutes, overtimeSeconds, type;

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
