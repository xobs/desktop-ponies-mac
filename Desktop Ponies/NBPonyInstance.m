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
    origin = NSMakePoint(200, 200);
    
    return self;
}

- (NBPonyBehavior *)startRandomBehavior {
    NSArray *behaviors = [_pony behaviorsAsArray];
    NSUInteger totalBehaviors = [behaviors count];
    NSMutableArray *array = [NSMutableArray array];
    
    /* First, figure out the total probability of behaviors that are appropriate */
    double probability = 0;
    for (NBPonyBehavior *b in behaviors) {
        if ([_delegate behaviorIsAppropriate:b forInstance:self]) {
            [array addObject:b];
            probability += [b probability];
        }
    }
    
    /* There are no appropriate behaviors, so place the instance
     * at the center and try again
     */
    if (![array count]) {
        origin = NSMakePoint(200, 200);
        return [self startRandomBehavior];
    }
    
    /* Next, pick a random number between 0 and the total */
    double value = random()/(double)RAND_MAX*probability;

    totalBehaviors = [array count]-1;
    for (NBPonyBehavior *p in array) {
        value -= [p probability];
        if (value < 0) {
            _behavior = p;
            break;
        }
    }

    currentFrame = 0;

    [self didChangeBehavior];    
    return _behavior;
}

- (NBPonyBehavior *)startBehavior:(NBPonyBehavior *)behavior
{
    _behavior = behavior;
    currentFrame = 0;
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
    
    // Add a timer to move to a new behavior after this one ends.
    timeTillNewBehavior = [_behavior randomTimeout]*1000;
}

#pragma mark -
#pragma mark Tick

- (int)currentFrame
{
    return currentFrame;
}

- (void)tick:(long long)elapsed
{
    timeTillNewBehavior -= elapsed;
    if (timeTillNewBehavior < 0) {
        [_delegate behaviorTimeoutExpiredForInstance:self];
    }
    
    if (horiz || vert) {
        NSSize movement = NSMakeSize(sqrt(speed*2)*horiz*cos(angle) + origin.x,
                                     sqrt(speed*2)*vert*sin(angle) + origin.y);

        if (![_delegate wouldFitOnScreen:movement forInstance:self]) {
            NSSize newMovement = [_delegate makeBestBounce:movement forInstance:self];
        
            if (newMovement.width != movement.width)
                horiz *= -1;
            if (newMovement.height != movement.height)
                vert *= -1;
        
            movement = NSMakeSize(sqrt(speed*2)*horiz*cos(angle) + origin.x,
                                  sqrt(speed*2)*vert*sin(angle) + origin.y);

            //NSLog(@"Now pointing %s and %s, angle %lf", vert==up?"up":(vert==down?"down":"none"), horiz==left?"left":(horiz==right?"right":"none"), angle);
        }
        origin.x = movement.width;
        origin.y = movement.height;
    }
    
    
    while (elapsed > 0 && [[self image] delayForFrame:currentFrame]) {
        if (elapsed > millisLeft) {
            elapsed -= millisLeft;
            currentFrame++;
            if (currentFrame >= [[self image] totalFrames])
                currentFrame = 0;
            millisLeft = [[self image] delayForFrame:currentFrame];
        }
        else {
            millisLeft -= elapsed;
            elapsed = 0;
        }
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
    origin = point;
}

- (void)endDragAtPoint:(NSPoint)point
{
    dragging = NO;
    [self startRandomBehavior];
}

- (void)dragToPoint:(NSPoint)point
{
    return;
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
    _delegate = delegate;
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

- (NBGraphicsSequence *)image
{
    if (horiz == left)
        return [_behavior leftImage];
    return [_behavior rightImage];
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

- (NSPoint)origin
{
    return origin;
}

- (void)setOrigin:(NSPoint)pt {
    origin = pt;
}

@end


