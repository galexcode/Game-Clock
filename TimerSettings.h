//
//  TimerSettings.h
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TimerType {
    Absolute,
    Bronstein,
    ByoYumi,
    Canadian,
    Fischer,
    Hourglass,
};

@interface TimerSettings : NSObject
{
    enum TimerType type;
    
    unsigned hours;
    unsigned minutes;
    unsigned seconds;
    
    unsigned periods;
    unsigned overtimeMinutes;
    unsigned overtimeSeconds;
}

@property (assign) unsigned hours, minutes, seconds, periods, overtimeMinutes, overtimeSeconds;
@property (assign) enum TimerType type;

+ (NSArray *) TimerTypes;

@end
