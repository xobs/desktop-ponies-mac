//
//  NBPonyInstance.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "NBPony.h"
#import "NBPonyWindow.h"

@class NBPonyInstance;
@class NBPonyWindow;

#define none 0
#define left -1
#define right 1
#define up 1
#define down -1

@interface NBPonyInstance : NSObject {
    NBPony *_pony;
    NBPonyBehavior *_behavior;
    NSTimer *_newBehaviorTimeout;
    
    int horiz;
    int vert;
    
    double old_speed;
    NBPonyBehavior *old_behavior;
    int old_vert;
    
    double angle, realAngle;
    double speed;
    
    NBPonyWindow *_window;
    BOOL dragging;
}

- (NBPonyInstance *)initWithPony:(NBPony *)pony;
- (NBPonyBehavior *)startRandomBehavior;
- (NBPonyBehavior *)startBehavior:(NBPonyBehavior *)behavior;
- (NBPonyBehavior *)behavior;
- (NSString *)imagePath;
- (NSImage *)image;
- (NSData *)imageData;
- (NSPoint)imageCenter;
- (int)facing;

- (NBPony *)pony;
- (void)setDelegate:(id)delegate;

- (void)didChangeBehavior;

- (void)tick;

- (void)beginDragAtPoint:(NSPoint)point;
- (void)endDragAtPoint:(NSPoint)point;
- (void)dragToPoint:(NSPoint)point;
- (void)mouseEntered:(NSEvent *)event;
- (void)mouseExited:(NSEvent *)anEvent;

- (void)showWindow;

@end


@interface NSObject (NBPonyInstanceDelegate)

- (void)behaviorTimeoutExpiredForInstance:(NBPonyInstance *)instance;
- (void)performMovement:(NSSize)delta forInstance:(NBPonyInstance *)instance;
- (BOOL)shouldBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance;
- (NSSize)makeBestBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance;
- (void)invalidateGraphicsForInstance:(NBPonyInstance *)instance;
- (BOOL)wouldFitOnScreen:(NSSize)newSize forInstance:(NBPonyInstance *)instance;
- (void)moveToPoint:(NSPoint)point forInstance:(NBPonyInstance *)instance;

- (BOOL)behaviorIsAppropriate:(NBPonyBehavior *)behavior forInstance:(NBPonyInstance *)instance;

@end
