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

#import "AppDelegate.h"
#import "ActivatedTimer.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize settings, timerActive;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    timerActive = NO;

    // set up the timer settings using the last
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary * lastTimerDict = [prefs dictionaryForKey:@"Last Timer Settings"];
    settings = [[TimerSettings alloc] initWithDictionary:lastTimerDict];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void) storeCurrentSettings
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[settings toDictionary] forKey:@"Last Timer Settings"];

}

- (void) tickOccurred:(ActivatedTimer *) timer
{

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


@end
