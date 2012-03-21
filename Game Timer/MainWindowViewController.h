//
//  MainWindowViewController.h
//  Game Timer
//
//  Created by Josh Guffin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainWindowViewController : UIViewController {
    IBOutlet UITabBar * tabBar;
}

- (IBAction)selectNewTimer:(id)sender;
- (IBAction)selectFavorites:(id)sender;


/* Tab bar delegate methods */
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
@end
