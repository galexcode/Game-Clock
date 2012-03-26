//
//  TimerSettings.h
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    Absolute,
    Bronstein,
    ByoYomi,
    Canadian,
    Fischer,
    Hourglass,
} TimerType;

@interface TimerSettings : NSObject

@property (assign) unsigned hours_, minutes_, seconds_, overtimePeriods_, overtimeMinutes_, overtimeSeconds_;
@property (assign) TimerType type_;

- (id) initWithHours:(unsigned)hours
             minutes:(unsigned)minutes
             seconds:(unsigned)seconds
     overtimeMinutes:(unsigned)overtimeMinutes
     overtimeSeconds:(unsigned)overtimeSeconds
             overtimePeriods:(unsigned)overtimePeriods
                type:(TimerType)type;

- (NSDictionary *) toDictionary;
- (id) initWithDictionary:(NSDictionary *) dict;

+ (NSArray *) TimerTypes;

@end
