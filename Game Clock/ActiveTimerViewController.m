//
//  ActiveTimerViewController.m
//  Game Clock
//
//  Created by Josh Guffin on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActiveTimerViewController.h"
#import "AppDelegate.h"
#import "ActivatedTimer.h"

@interface ActiveTimerViewController ()

@end

@implementation ActiveTimerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [white layoutSubviews];
    [black layoutSubviews];
    
    // clear fields
    [whiteMain   setText:@""];
    [whiteStatus setText:@""];
    [blackMain   setText:@""];
    [blackStatus setText:@""];
    
    /*
    [whiteMain setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:150.0f]];
    [blackMain setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:150.0f]];
    */
    
    // Connect the application's AppDelegate instance to this view
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    timer       = [appDelegate activeTimer];
    timerDescription = [timer description];
    
    [timer setAtvc:self];
    
    // Rotate the white view
    white.transform = CGAffineTransformMakeRotation (M_PI);

    white.backgroundColor = [UIColor blackColor];
    black.backgroundColor = [UIColor blackColor];

    // TODO: remove
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"Basic"
                                                          ofType:@"tpl" 
                                                     inDirectory:@"templates"];  
    templateString = [[NSString alloc] initWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    [self updateViewForPlayer:White];
    [self updateViewForPlayer:Black];
    
    [self activate];
}

- (void) tick:(NSTimer*)sender
{
    [timer tick];
    if ([timer whoseTurn] == White)
        [self updateViewForPlayer:White];
    else
        [self updateViewForPlayer:Black];
}


- (void) activate
{
    [self tick:nil];
    // start the ticker
    ticker = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void) deactivate
{
    [ticker invalidate];
    ticker = nil;
}

#define REPLACE(x,y,z) [x replaceOccurrencesOfString:@#y withString:z options:0 range:NSMakeRange(0,[x length])];

- (void) updateViewForPlayer:(Player) player
{
    TimeData data;
    NSString * playerString = nil;
    UIView * view = nil;
    UILabel * main = nil;
    UILabel * stat = nil;
    
    if (player == White) {
        data = [timer whiteTime];
        main = whiteMain;
        stat = whiteStatus;
        view = white;
        playerString = @"White";
    }
    else {
        data = [timer blackTime];
        main = blackMain;
        stat = blackStatus;
        view = black;
        playerString = @"Black";
    }
    
    TimerType type = [timer type];
    
    // find the time remaining in hours/minutes/seconds
    unsigned decisec = (data.mainDeciseconds % 10);
    unsigned seconds = (data.mainDeciseconds / 10) % 60;
    unsigned minutes = (data.mainDeciseconds / 600) % 60;
    unsigned hours   = (data.mainDeciseconds / 36000);

    unsigned otdecisec = (data.overtimeDeciseconds % 10);
    unsigned otseconds = (data.overtimeDeciseconds / 10) % 60;
    unsigned otminutes = (data.overtimeDeciseconds / 600);
    
    NSString * mainString = nil;
    NSString * statString = [NSString stringWithFormat:@"%@ - %@", playerString, timerDescription];

    if (hours > 0)
        mainString = [NSString stringWithFormat:@"%d:%02d:%02d.%d", hours, minutes, seconds, decisec];
    else
        mainString = [NSString stringWithFormat:@"%d:%02d.%d", minutes, seconds, decisec];
    
    if (type == Absolute || type == Hourglass) {
        [main setText:mainString];
        [stat setText:statString];
        return;
    }
    
    // The status line indicates additional time per move
    if (type == Fischer || type == Bronstein) {
        [main setText:mainString];
        [stat setText:[NSString stringWithFormat:@"%@", statString]];
        return;
    }
    
    // ByoYomi/Canadian
    if (data.mainDeciseconds == 0) {
        mainString = [NSString stringWithFormat:@"%d:%02d.%d (%d)", otminutes, otseconds, otdecisec, data.periods];
        [main setText:mainString];
    }
    else
        [main setText:mainString];

    [stat setText:statString];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * tap = (UITouch *) [touches anyObject];

    UIView * tapped = [tap view];
    if ((tapped == white && [timer whoseTurn] == White) ||
        (tapped == black && [timer whoseTurn] == Black))
    {
        [timer swapPlayer];
        
        // TODO: make flashing a preference
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [tapped setBackgroundColor:[UIColor whiteColor]];
        [tapped setBackgroundColor:[UIColor blackColor]];
    }
}

@end
