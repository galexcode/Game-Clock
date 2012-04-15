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
