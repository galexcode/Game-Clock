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

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

const float MAIN_TEXT_SIZE   = 150.0;
const float OVER_PERIOD_SIZE = 100.0;
const float DECISECOND_SIZE  = 75.0;

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
    
    [self updateViewForPlayer:White hasExpired:NO];
    [self updateViewForPlayer:Black hasExpired:NO];
    
    [self activate];
}

- (void) tick:(NSTimer*)sender
{
    [timer tick];
    
    BOOL expired = [timer hasExpired];
    if (expired)
        [self deactivate];
    
    static BOOL update = false;
    update = !update;

    // update for both players because some timers update both times
    if ([timer whoseTurn] == White) {
        [self updateViewForPlayer:White hasExpired:expired];
        [self updateViewForPlayer:Black hasExpired:NO];
    }
    else {
        [self updateViewForPlayer:Black hasExpired:expired];
        [self updateViewForPlayer:White hasExpired:NO];
    }
}


- (void) activate
{
    // start the ticker
    ticker = [NSTimer scheduledTimerWithTimeInterval:0.1f
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

- (void) updateViewForPlayer:(Player) player hasExpired:(BOOL) expired
{
    TimeData data;
    NSString * playerString = nil;
    UIView * view = nil;
    OHAttributedLabel * main = nil;
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
    
    BOOL isActive = player == [timer whoseTurn];
    
    TimerType type = [timer type];
    unsigned remaining = data.mainDeciseconds;
    
    // Show remaining periods for ByoYomi/Canadian timers
    int periods = -1;
    if (remaining == 0) {
        if (type == ByoYomi || type == Canadian)
            periods = data.periods;
        remaining = data.overtimeDeciseconds;
    }
    
    NSString * statString = [NSString stringWithFormat:@"%@ - %@", playerString, timerDescription];
    NSAttributedString * mainString = [self attributedString:remaining periods:periods isActive:isActive];
    
    [main setAttributedText:mainString];
    [main setTextAlignment:UITextAlignmentCenter];
    [stat setText:statString];
    
    // time ran out
    if (expired)
        [main setBackgroundColor:[UIColor colorWithRed:0.5 green:0 blue:0 alpha:1.0]];
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
    // timer is not active
    if (ticker == nil)
        return;
    
    UITouch * tap = (UITouch *) [touches anyObject];

    // user clicked for their move
    UIView * tapped = [tap view];
    if ((tapped == white && [timer whoseTurn] == White) ||
        (tapped == black && [timer whoseTurn] == Black))
    {
        [timer swapPlayer];
        
        // time may have changed due to ByoYomi, Hourglass, etc
        [self updateViewForPlayer:White hasExpired:NO];
        [self updateViewForPlayer:Black hasExpired:NO];
        
        // TODO: make flashing a preference
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [tapped setBackgroundColor:[UIColor whiteColor]];
        [tapped setBackgroundColor:[UIColor blackColor]];
    }
}

- (NSAttributedString *) attributedString:(unsigned) deciseconds 
                                  periods:(int) periods
                                 isActive:(BOOL)isActive
{
    // find the time remaining in hours/minutes/seconds
    unsigned decisec = (deciseconds % 10);
    unsigned seconds = (deciseconds / 10) % 60;
    unsigned minutes = (deciseconds / 600) % 60;
    unsigned hours   = (deciseconds / 36000);
    
    // create attributed string for main time
    NSString * mainString;
    
    if (hours > 0)
        mainString = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    else
        mainString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    NSString * deciString = [NSString stringWithFormat:@".%d", decisec];
    
    static UIFont * mainDisplayFont = nil;
    static UIFont * decisecondFont  = nil;
    static UIFont * periodsFont     = nil;
    static UIColor * activeColor    = nil;
    static UIColor * inactiveColor  = nil;
    if (!mainDisplayFont) {
        mainDisplayFont = [UIFont systemFontOfSize:MAIN_TEXT_SIZE];
        decisecondFont  = [UIFont systemFontOfSize:DECISECOND_SIZE];
        periodsFont     = [UIFont systemFontOfSize:OVER_PERIOD_SIZE];
        activeColor     = [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1.0];
        inactiveColor   = [UIColor whiteColor];
    }
    
    UIColor * fontcolor = (isActive && ticker != nil ? activeColor : inactiveColor);
    
    NSMutableAttributedString * fancyMain = 
    [[NSMutableAttributedString alloc] initWithString:mainString];
    [fancyMain setFont:mainDisplayFont];
    [fancyMain setTextColor:fontcolor];
    
    NSMutableAttributedString * fancyDeci = 
    [[NSMutableAttributedString alloc] initWithString:deciString];
    [fancyDeci setFont:decisecondFont];
    [fancyDeci setTextColor:fontcolor];
    
    [fancyMain appendAttributedString:fancyDeci];
    
    // show the remaining periods in Canadian/ByoYomi
    if (periods >= 0) {
        
        NSMutableAttributedString * fancyTimes = 
        [[NSMutableAttributedString alloc] initWithString:@"    ×"];
        [fancyTimes setFont:decisecondFont];
        [fancyTimes setTextColor:fontcolor];
        
        NSString * periodString = [NSString stringWithFormat:@"%d", periods];
        NSMutableAttributedString * fancyPeriods = 
        [[NSMutableAttributedString alloc] initWithString:periodString];
        [fancyPeriods setFont:periodsFont];
        [fancyPeriods setTextColor:fontcolor];
        
        
        [fancyMain appendAttributedString:fancyTimes];
        [fancyMain appendAttributedString:fancyPeriods];
    }
    
    
    return [fancyMain copy];
}

@end
