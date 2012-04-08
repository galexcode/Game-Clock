//
//  ActiveTimerViewController.h
//  Game Clock
//
//  Created by Josh Guffin on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class ActivatedTimer;

@interface ActiveTimerViewController : UIViewController
{
    AppDelegate * appDelegate;
    ActivatedTimer * timer;
    NSTimer * ticker;
    
    NSString * templateString;
    
    IBOutlet UIWebView * upper;
    IBOutlet UIWebView * lower;
}

- (void) tick:(NSTimer*)sender;


@end
