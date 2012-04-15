// Copyright 2012 Josh Guffin
//
// This file is part of Game Clock
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>

@class AppDelegate;
@class ActivatedTimer;
@class OHAttributedLabel;

@interface ActiveTimerViewController : UIViewController
{
    AppDelegate * appDelegate;
    ActivatedTimer * timer;
    NSTimer * ticker;
    
    NSString * templateString;
    NSString * timerDescription;
    
    IBOutlet UIView * white;
    IBOutlet UIView * black;
    
    IBOutlet OHAttributedLabel * whiteMain;
    IBOutlet UILabel * whiteStatus;
    IBOutlet OHAttributedLabel * blackMain;
    IBOutlet UILabel * blackStatus;
    
}

- (void) tick:(NSTimer*)sender;


@end
