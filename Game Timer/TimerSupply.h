//
//  TimerSupply.h
//  Game Timer
//
//  Created by Josh Guffin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerSupply : NSObject
{
    NSString * categoryChoices;
}

- (NSString *) titleForCategory:(NSUInteger) row;
- (NSString *) titleForItem:(NSUInteger) row inCategory:(NSUInteger) category;

@end
