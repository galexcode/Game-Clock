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

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize settings, activeTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    activeTimer = nil;

    // set up the timer settings using the last
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary * lastTimerDict = [prefs dictionaryForKey:@"Last Timer Settings"];
    settings = [[TimerSettings alloc] initWithDictionary:lastTimerDict];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an
     incoming phone call or SMS message) or when the user quits the application
     and it begins the transition to the background state.  Use this method to
     pause ongoing tasks, disable timers, and throttle down OpenGL ES frame
     rates. Games should use this method to pause the game.
     */

    [self pauseAndStore:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self pauseAndStore:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive
     state; here you can undo many of the changes made on entering the
     background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the
     application was inactive. If the application was previously in the
     background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self pauseAndStore:YES];
}

/**
 * Write the activated timer to disk; i.e. store a paused game
 */
- (void) pauseAndStore:(BOOL) delete
{
    // game is not currently running
    if (activeTimer == nil || [activeTimer atvc] == nil)
        return;

    // turn off the timer
    [[activeTimer atvc] deactivate];

    // extract stored timers from preferences
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * timersFromPrefs = [[prefs dictionaryForKey:@"Timers"] mutableCopy];
    NSMutableDictionary * pausedTimers    = [[timersFromPrefs objectForKey:@"Paused"] mutableCopy];

    // check if this one is already stored
    unsigned timerID = [activeTimer timerID];
    for (NSString * paused in [pausedTimers allKeys])
    {
        NSDictionary * ptimer = [pausedTimers objectForKey:paused];
        if (timerID == [[ptimer objectForKey:@"id"] unsignedIntValue])
        {
            // remove old timer
            [pausedTimers removeObjectForKey:paused];
            break;
        }
    }

    // store the timer
    NSDictionary * serialized = [activeTimer toDictionary];
    [pausedTimers setValue:serialized forKey:[activeTimer description]];

    if (delete)
        activeTimer = nil;
}


- (void) storeCurrentSettings
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[settings toDictionary] forKey:@"Last Timer Settings"];
    [prefs synchronize];
}

- (void) launchWithPlayer:(Player) first
{
    activeTimer = nil;
    activeTimer = [[ActivatedTimer alloc] init:settings firstPlayer:first];
}

- (NSArray *) alreadyExists:(TimerSettings *) toCheck
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];

    // load preset timers
    NSDictionary * referenceDict = [[toCheck effectiveSettings] toDictionary];

    NSDictionary * timersFromPrefs = [prefs dictionaryForKey:@"Timers"];
    NSArray * keys  = [timersFromPrefs allKeys];

    for (NSString * key in keys) {
        // consider each timer collection
        NSDictionary * timerCollection = [timersFromPrefs objectForKey:key];
        if ([timerCollection count] == 0)
            continue;

        for (NSString * description in [timerCollection allKeys]) {
            // each timer in the timer collection
            NSDictionary * timer = [timerCollection objectForKey:description];

            if ([timer isEqualToDictionary:referenceDict])
                return [NSArray arrayWithObjects:key, description,nil];
        }
    }
    return nil;
}


// from http://stackoverflow.com/questions/4109587/how-to-localize-a-timer-on-iphone
+ (NSString*)timeComponentSeparator
{
    // Make a sample date (one day, one minute, two seconds)
    NSDate *aDate = [NSDate dateWithTimeIntervalSinceReferenceDate:((24*60*60)+62)];

    // Get the localized time string
    NSDateFormatter *aFormatter = [[NSDateFormatter alloc] init];
    [aFormatter setDateStyle:NSDateFormatterNoStyle];
    [aFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *aTimeString = [aFormatter stringFromDate:aDate]; // Not using +localizedStringFromDate... because it is iOS 4.0+

    // Get time component separator
    NSCharacterSet *aCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@":-."];
    NSRange aRange = [aTimeString rangeOfCharacterFromSet:aCharacterSet];
    NSString *aTimeComponentSeparator = [aTimeString substringWithRange:aRange];

    // Failsafe
    if ([aTimeComponentSeparator length] != 1)
    {
        aTimeComponentSeparator = @":";
    }

    return aTimeComponentSeparator;
}


@end
