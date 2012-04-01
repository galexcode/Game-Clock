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

#ifndef TimerSupply_h_included
#define TimerSupply_h_included

#import <Foundation/Foundation.h>

@interface TimerSupply : NSObject
{
    NSUserDefaults *prefs;
    NSDictionary * timers;
}

- (void) createTimersFromDictionary:(NSDictionary *) dict;
- (NSUInteger) rowsInComponent:(NSUInteger) component;
- (NSString *) titleForItem:(NSUInteger) row inComponent:(NSUInteger) component;
- (void) createInitialObjects;

+ (NSArray *) keys;

@end

#endif
