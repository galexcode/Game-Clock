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
    
    [self performSegueWithIdentifier:@"Create" sender:item];
    

}

- (void) viewDidLoad
{
    NSLog(@"loaded hoe!");
    NSArray * items = [tabBar items];
    [tabBar setSelectedItem:[items objectAtIndex:1]];
    [[items objectAtIndex:0] setEnabled:false];
    NSLog(@"Enabled 1");
}

@end
