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
    
    // Connect the application's AppDelegate instance to this view
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    timer       = [appDelegate activeTimer];
    
    [timer setAtvc:self];
    
    // Rotate the upper view
    upper.transform = CGAffineTransformMakeRotation (M_PI);

    upper.backgroundColor = [UIColor blackColor];
    lower.backgroundColor = [UIColor blackColor];

    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"Basic"
                                                          ofType:@"tpl" 
                                                     inDirectory:@"templates"];  
    templateString = [[NSString alloc] initWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    [self updateTimerView:upper forPlayer:White];
    [self updateTimerView:lower forPlayer:Black];
}

- (void) tick:(NSTimer*)sender
{
    [timer tick];
    if ([timer whoseTurn] == White)
        [self updateTimerView:upper forPlayer:White];
    else
        [self updateTimerView:lower forPlayer:Black];
}


- (void) activate
{
    // start the ticker
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.0f
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

- (void) updateTimerView:(UIWebView *) view forPlayer:(Player) player
{
    TimeData data;
    if (player == White)
        data = [timer whiteTime];
    else
        data = [timer blackTime];
    
    unsigned decisec = (data.mainDeciseconds % 10);
    unsigned seconds = (data.mainDeciseconds / 10) % 60;
    unsigned minutes = (data.mainDeciseconds / 600) % 60;
    unsigned hours   = (data.mainDeciseconds / 36000);
    
    NSString * mainString = [NSString stringWithFormat:@"%d:%02d:%02d.%d", hours, minutes, seconds, decisec];
    
    NSMutableString * html = [NSMutableString stringWithString:templateString];
    
    REPLACE(html, $maintime, mainString);
    REPLACE(html, $periods, @"");
    REPLACE(html, $overtime, @"");
    
    TimerType type = [timer type];
    if (type == Absolute || type == Hourglass)
    {
        
    }
    
    [view loadHTMLString:html baseURL:nil];
    
    /*
    @property (readonly) TimeData whiteTime, blackTime;
    @property (readonly) TimerType type;
    @property (readonly) BOOL hasExpired;
    
    // whose turn it currently is, and who had the first timer
    @property (readonly) Player startingPlayer;
    @property (assign) Player whoseTurn;
    */
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

@end
