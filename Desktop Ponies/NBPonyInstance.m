//
//  NBPonyInstance.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyInstance.h"
#define MAX_TRIES 200 // Number of times it will try for a behavior before giving up

@implementation NBPonyInstance

- (NBPonyInstance *)initWithPony:(NBPony *)pony
{
    if (!(self = [super init]))
        return nil;
    _pony = [pony retain];
    srandomdev();
    
    [self startRandomBehavior];
    
    return self;
}

- (NBPonyBehavior *)startRandomBehavior {
    int tries;
    NSArray *behaviors = [_pony behaviorsAsArray];
    NSUInteger totalBehaviors = [behaviors count];
    NBPonyBehavior *newBehavior = nil;
    
    if ([[_pony name] isEqualToString:@"Rainbow Dash"])
        return _behavior = [_pony behaviorNamed:@"drag"];
    
    for (tries=0; tries<MAX_TRIES && newBehavior == nil; tries++) {
        double value = random()/(double)RAND_MAX*[_pony behaviorProbabilityTotal];
        double count;
        unsigned int i;
        for (i=0, count=0; i<totalBehaviors && count<value; i++)
            count += [[behaviors objectAtIndex:i] probability];
        if (i>=totalBehaviors) {
            NSLog(@"Warning: Exceeded total behaviors");
            i=0;
        }
        if ([[behaviors objectAtIndex:i] shouldSkip])
            continue;
        
        newBehavior = [behaviors objectAtIndex:i];
    }

    if (!newBehavior) {
        NSLog(@"Warning: Couldn't decide on a behavior, so picking behavior 0");
        newBehavior = [behaviors objectAtIndex:0];
    }
    
    _behavior = newBehavior;
    NSLog(@"Starting behavior %@", [_behavior name]);
    [self didChangeBehavior];    
    return _behavior;
}

- (NBPonyBehavior *)startBehavior:(NBPonyBehavior *)behavior
{
    // XXX Check to make sure [behavior] is in [_pony behaviors].
    _behavior = behavior;
    [self didChangeBehavior];
    return _behavior;
}

- (void)didChangeBehavior
{
    NSTimeInterval timeTillNewBehavior = [_behavior randomTimeout];
    if (_newBehaviorTimeout)
        [_newBehaviorTimeout invalidate];
    
    _newBehaviorTimeout = [NSTimer scheduledTimerWithTimeInterval:timeTillNewBehavior
                                                           target:self
                                                         selector:@selector(behaviorExpired:)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)behaviorExpired:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(behaviorTimeoutExpired:)])
        [_delegate behaviorTimeoutExpired:self];

}

#pragma mark -
#pragma mark Accessors and setters


- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

- (NBPonyBehavior *)behavior
{
    return _behavior;
}

- (NBPony *)pony
{
    return _pony;
}

@end
