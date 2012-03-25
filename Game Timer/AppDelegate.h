//
//  AppDelegate.h
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerSettings.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain) TimerSettings * settings;
@property (strong, nonatomic) UIWindow *window;

@end
