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

#ifndef AppDelegate_h_included
#define AppDelegate_h_included

#import <UIKit/UIKit.h>
#import "TimerSettings.h"
#import "ActivatedTimer.h"
@class TimerSettings;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain) TimerSettings * settings;
@property (strong, nonatomic) UIWindow *window;
@property (retain) ActivatedTimer * activeTimer;


- (void) launchWithPlayer:(Player) first;
- (NSArray *) alreadyExists:(TimerSettings *) toCheck;
- (void) storeCurrentSettings;

@end

#endif
