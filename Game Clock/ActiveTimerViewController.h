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
    NSString * timerDescription;
    
    IBOutlet UIView * white;
    IBOutlet UIView * black;
    
    IBOutlet UILabel * whiteMain;
    IBOutlet UILabel * whiteStatus;
    IBOutlet UILabel * blackMain;
    IBOutlet UILabel * blackStatus;
    
}

- (void) tick:(NSTimer*)sender;


@end
