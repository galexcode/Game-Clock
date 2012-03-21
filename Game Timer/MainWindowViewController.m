//
//  MainWindowViewController.m
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainWindowViewController.h"

@implementation MainWindowViewController

- (IBAction)selectNewTimer:(id)sender
{
    NSLog(@"selected new");
}

- (IBAction)selectFavorites:(id)sender
{
    NSLog(@"selected favorites");
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = [item tag];
    NSLog(@"Dropped a %d BIITCH!!!!", tag);
}

- (void) viewDidLoad
{
    NSLog(@"loaded hoe!");
    [tabBar setSelectedItem:[[tabBar items] objectAtIndex:1]];
    NSLog(@"Enabled 1");
}

@end
