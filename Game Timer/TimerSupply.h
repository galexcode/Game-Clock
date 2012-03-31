//
//  TimerSupply.h
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
