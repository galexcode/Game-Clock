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

// constructors && helpers
- (id) initWithDictionary:(NSDictionary *) dict;
- (id) initWithHours:(unsigned)_hours
             minutes:(unsigned)_minutes
             seconds:(unsigned)_seconds
     overtimeMinutes:(unsigned)_overtimeMinutes
     overtimeSeconds:(unsigned)_overtimeSeconds
             overtimePeriods:(unsigned)_overtimePeriods
                type:(TimerType)_type;
- (void) populateDefaults;

- (BOOL) isEqual:(TimerSettings *) other;
- (NSString*) validateSettings;
- (NSDictionary *) toDictionary;
- (TimerSettings *) effectiveSettings;

// static methods
+ (NSArray *) TimerTypes;
+ (NSString *) StringForType:(TimerType) type;
+ (NSUInteger) IndexForType:(TimerType) type;
+ (TimerSettings *) DefaultTimerForType:(TimerType) type;
@end

#endif
