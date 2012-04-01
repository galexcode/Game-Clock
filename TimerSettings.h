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

#ifndef TimerSettings_h_included
#define TimerSettings_h_included

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

/**
 * In Canadian timing, overtimePeriods represents the number of required moves
 * per period, while in ByoYomi timing, it is the actual number of overtime periods.
 */

@property (assign) unsigned hours, minutes, seconds, overtimePeriods, overtimeMinutes, overtimeSeconds;
@property (assign) TimerType type;

- (id) initWithHours:(unsigned)_hours
             minutes:(unsigned)_minutes
             seconds:(unsigned)_seconds
     overtimeMinutes:(unsigned)_overtimeMinutes
     overtimeSeconds:(unsigned)_overtimeSeconds
             overtimePeriods:(unsigned)_overtimePeriods
                type:(TimerType)_type;

- (BOOL) isEqual:(TimerSettings *) other;
- (void) populateDefaults;
- (NSString*) validateSettings;
- (NSDictionary *) toDictionary;
- (id) initWithDictionary:(NSDictionary *) dict;

+ (NSArray *) TimerTypes;
+ (NSString *) StringForType:(TimerType) type;
+ (NSUInteger) IndexForType:(TimerType) type;
+ (TimerSettings *) DefaultTimerForType:(TimerType) type;
@end

#endif
