// Copyright 2012 Josh Guffin
//
// This file is part of Game Clock
//
// Game Clock is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Game Clock is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// Game Clock. If not, see http://www.gnu.org/licenses/.

#ifndef ActivatedTimer_h_included
#define ActivatedTimer_h_included

#import <Foundation/Foundation.h>
#import "TimerSettings.h"
#import "ActiveTimerViewController.h"

@class AppDelegate;

typedef enum {
    Black,
    White
} Player;

typedef struct {
    unsigned moves, mainDeciseconds, periods, overtimeDeciseconds;
} TimeData;

@interface ActivatedTimer : NSObject
{
    AppDelegate * appDelegate;
    TimerSettings * settings;
    NSTimer * ticker;
    
    NSUInteger timeExpendedThisTurn;
}

@property (readonly) TimeData whiteTime, blackTime;
@property (readonly) TimerType type;
@property (readonly) BOOL hasExpired;
@property (assign) ActiveTimerViewController * atvc;

// whose turn it currently is, and who had the first timer
@property (readonly) Player startingPlayer;
@property (assign) Player whoseTurn;

- (id) init:(TimerSettings *) settings firstPlayer:(Player) player;
- (id) init:(NSDictionary *) dict;
- (NSDictionary *) toDictionary;

- (void) tick;
- (void) swapPlayer;

- (NSString *) description;

// Decrements the timer, returning YES if time has expired
- (BOOL) decrementAbsolute:(TimeData *) data;
- (BOOL) decrementBronstein:(TimeData *) data;
- (BOOL) decrementFischer:(TimeData *) data;
- (BOOL) decrementByoYomi:(TimeData *) data;
- (BOOL) decrementCanadian:(TimeData *) data;
- (BOOL) decrementHourglass:(TimeData *) one notMoving:(TimeData*) two;

@end

#endif
