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
    
    _window = [[NBPonyWindow alloc] initWithContentRect:NSMakeRect(100, 500, 50, 50)
                                                        styleMask:NSBorderlessWindowMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:YES];
    [_window setPonyInstance:self];
        
    return self;
}

- (void)showWindow
{
    [_window makeKeyAndOrderFront:self];
}

- (NBPonyBehavior *)startRandomBehavior {
    int tries;
    NSArray *behaviors = [_pony behaviorsAsArray];
    NSUInteger totalBehaviors = [behaviors count];
    NBPonyBehavior *newBehavior = nil;
    
    for (tries=0; tries<MAX_TRIES && newBehavior == nil; tries++) {
        double value = random()/(double)RAND_MAX*[_pony behaviorProbabilityTotal];
        double count;
        unsigned int i;
        NBPonyBehavior *behavior;
        for (i=0, count=0; i<totalBehaviors && count<value; i++)
            count += [[behaviors objectAtIndex:i] probability];
        if (i>=totalBehaviors) {
            NSLog(@"Warning: Exceeded total behaviors");
            i=0;
        }
        
        behavior = [behaviors objectAtIndex:i];
        if (![_window behaviorIsAppropriate:behavior forInstance:self])
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
    // Recalculate movement data.
    int flags = [_behavior movementFlags];
    // Flags indicate it's either "no movement" or "sleeping/mouseover/dragged"
    if (!(flags&MOVEMENT_ALL)) {
        vert = none;
        
        horiz = left;
        if (random()&1)
            horiz = right;
        angle = 0;
        speed = 0;
    }
    else {
        int choice;
        // Find a random number between 0 and 2.
        do {
            choice = random()&3;
        } while (!choice);
        
        // Determine which movement to make (horizontal, vertical, or diagonal).
        while (!(choice & flags)) {
            choice <<= 1;
            if (choice > MOVEMENT_ALL)
                choice = 1;
        }
        
        horiz = none;
        vert = none;
        angle = M_PI_2 * random() / (double)RAND_MAX;
        
        if (choice == MOVEMENT_VERT)
            angle = M_PI_2;
        if (choice == MOVEMENT_HORIZ)
            angle = 0;

        if (choice & MOVEMENT_VERT_DIAG)
            vert = (random()&1)?up:down;
        
        if (choice & MOVEMENT_HORIZ_DIAG)
            horiz = (random()&1)?left:right;
        
        //NSLog(@"Now pointing %s and %s, angle %lf", vert==up?"up":(vert==down?"down":"none"), horiz==left?"left":(horiz==right?"right":"none"), angle);

        speed = [_behavior speed] * [_pony scale];
    }
    speed = speed * speed;
    
    [_window invalidateGraphicsForInstance:self];
    
    // Add a timer to move to a new behavior after this one ends.
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
    [_window behaviorTimeoutExpiredForInstance:self];
}

#pragma mark -
#pragma mark Tick

- (void)tick
{
    if (horiz || vert) {
        NSSize movement = NSMakeSize(sqrt(speed*2)*horiz*cos(angle), sqrt(speed*2)*vert*sin(angle));
    
        if ([_window shouldBounce:movement forInstance:self]) {
            NSSize newMovement = [_window makeBestBounce:movement forInstance:self];
        
            if (newMovement.width != movement.width)
                horiz *= -1;
            if (newMovement.height != movement.height)
                vert *= -1;
        
            movement = NSMakeSize(sqrt(speed*2)*horiz*cos(angle), sqrt(speed*2)*vert*sin(angle));

            [_window invalidateGraphicsForInstance:self];
            //NSLog(@"Now pointing %s and %s, angle %lf", vert==up?"up":(vert==down?"down":"none"), horiz==left?"left":(horiz==right?"right":"none"), angle);
        }
        [_window performMovement:movement forInstance:self];
    }
}

#pragma mark -
#pragma mark Mouse interaction
- (void)beginDragAtPoint:(NSPoint)point
{
    dragging = YES;
    old_speed = speed;
    old_behavior = _behavior;
    old_vert = vert;
    
    speed = 0;
    vert = none;
    horiz = none;
    for (NBPonyBehavior *b in [_pony behaviorsAsArray]) {
        if ([b movementFlags] == MOVEMENT_DRAGGING) {
            _behavior = b;
            break;
        }
    }
    [_newBehaviorTimeout invalidate];
    _newBehaviorTimeout = nil;
    [_window invalidateGraphicsForInstance:self];
    [_window moveToPoint:point forInstance:self];
}

- (void)endDragAtPoint:(NSPoint)point
{
    dragging = NO;
    [self startRandomBehavior];
}

- (void)dragToPoint:(NSPoint)point
{
    [_window moveToPoint:point forInstance:self];    
}

- (void)mouseEntered:(NSEvent *)anEvent
{
    if (dragging)
        return;
    old_speed = speed;
    old_behavior = _behavior;
    old_vert = vert;
    
    speed = 0;
    vert = none;
    for (NBPonyBehavior *b in [_pony behaviorsAsArray]) {
        if ([b movementFlags] == MOVEMENT_MOUSEOVER) {
            _behavior = b;
            break;
        }
    }
    [_newBehaviorTimeout invalidate];
    _newBehaviorTimeout = nil;
    [_window invalidateGraphicsForInstance:self];
}

- (void)mouseExited:(NSEvent *)anEvent
{
    if (dragging)
        return;
    [self startRandomBehavior];
}

#pragma mark -
#pragma mark Accessors and setters


- (void)setDelegate:(id)delegate
{
    _window = delegate;
}

- (NBPonyBehavior *)behavior
{
    return _behavior;
}

- (NSString *)imagePath
{
    if (horiz == left)
        return [_behavior leftImagePath];
    return [_behavior rightImagePath];
}

- (NSImage *)image
{
    if (horiz == left)
        return [_behavior leftImage];
    return [_behavior rightImage];
}

- (NSData *)imageData
{
    if (horiz == left)
        return [_behavior leftImageData];
    return [_behavior rightImageData];
}

- (NSPoint)imageCenter
{
    if (horiz == left)
        return [_behavior leftImageCenter];
    return [_behavior rightImageCenter];
}

- (NBPony *)pony
{
    return _pony;
}

- (int)facing
{
    return horiz;
}

@end


