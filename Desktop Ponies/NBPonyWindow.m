//
//  NBPonyWindow.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyWindow.h"

@implementation NBPonyWindow

- (id) initWithContentRect:(NSRect)contentRect
                 styleMask:(NSUInteger)aStyle
                   backing:(NSBackingStoreType)bufferingType
                     defer:(BOOL)flag
{
    if (!(self = [super initWithContentRect:contentRect
                                  styleMask:NSBorderlessWindowMask
                                    backing:bufferingType
                                      defer:flag]))
        return nil;
    
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    
    ponyView = [[WebView alloc] init];
    [ponyView setFrame:[self frameRectForContentRect:[self frame]]];
    [ponyView setEditable:NO];
    [ponyView setDrawsBackground:NO];
    [ponyView setEditable:NO];
    [ponyView setMaintainsBackForwardList:NO];
    [[[ponyView mainFrame] frameView] setAllowsScrolling:NO];
    
    [self setContentView:ponyView];
    
    return self;
}


- (void)setPonyInstance:(NBPonyInstance *)instance
{
    if (_instance)
        [_instance release];
    _instance = [instance retain];
    [_instance setDelegate:self];
    [_instance startRandomBehavior];
}


#pragma mark -
#pragma mark Delegate functions

- (void)behaviorTimeoutExpiredForInstance:(NBPonyInstance *)instance
{
    [instance startRandomBehavior];
    
    NSString *path = [instance imagePath];
    NSImage *image = [instance image];
    
    [ponyView setMainFrameURL:[NSString stringWithFormat:@"file://%@", path]];
    [self setContentSize:[image size]];
}

- (void)performMovement:(NSSize)delta forInstance:(NBPonyInstance *)instance
{
    NSRect f = [self frame];
    f.origin.x += delta.width;
    f.origin.y += delta.height;
    [self setFrameOrigin:f.origin];
}

- (BOOL)wouldFitOnScreen:(NSSize)newSize forInstance:(NBPonyInstance *)instance
{
    NSRect screenSize = [[NSScreen mainScreen] visibleFrame];
    NSRect currentFrame = [self frame];
    currentFrame.size = newSize;
    NSRect f = [self frameRectForContentRect:currentFrame];

    if (f.origin.x < screenSize.origin.x
        || f.origin.y < screenSize.origin.y
        || f.origin.x + f.size.width > screenSize.size.width + screenSize.origin.x
        || f.origin.y + f.size.height > screenSize.size.height + screenSize.origin.y)
        return NO;
    return YES;
}

- (BOOL)shouldBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance
{
    NSRect screenSize = [[NSScreen mainScreen] visibleFrame];
    NSRect f = [self frame];
    f.origin.x += delta.width;
    f.origin.y += delta.height;
    if (f.origin.x < screenSize.origin.x
     || f.origin.y < screenSize.origin.y
     || f.origin.x + f.size.width > screenSize.size.width + screenSize.origin.x
     || f.origin.y + f.size.height > screenSize.size.height + screenSize.origin.y)
        return YES;
    return NO;
}

- (NSSize)makeBestBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance
{
    NSRect screenSize = [[NSScreen mainScreen] visibleFrame];
    NSRect f = [self frame];
    f.origin.x += delta.width;
    f.origin.y += delta.height;
    
    if (f.origin.x < screenSize.origin.x)
        delta.width *= -1;
    else if (f.origin.x + f.size.width > screenSize.size.width + screenSize.origin.x)
        delta.width *= -1;

    if (f.origin.y < screenSize.origin.y)
        delta.height *= -1;
    else if (f.origin.y + f.size.height > screenSize.size.height + screenSize.origin.y)
        delta.height *= -1;
    
    return delta;
}

- (void)moveToPoint:(NSPoint)point forInstance:(NBPonyInstance *)instance
{
    NSPoint offset = [instance imageCenter];
    point.x -= offset.x;
    point.y += offset.y - [[instance image] size].height;
    [self setFrameOrigin:point];
}

- (void)invalidateGraphicsForInstance:(NBPonyInstance *)instance
{
    NSString *path = [instance imagePath];
    NSImage *image = [instance image];
    
    [ponyView setMainFrameURL:[NSString stringWithFormat:@"file://%@", path]];
    [self setContentSize:[image size]];
}


- (void)doTick
{
    [_instance tick];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void) sendEvent: (NSEvent *) event
{
    if ([event type] == NSLeftMouseDown)
        [_instance beginDragAtPoint:[NSEvent mouseLocation]];
    else if ([event type] == NSLeftMouseUp)
        [_instance endDragAtPoint:[NSEvent mouseLocation]];
    else if ([event type] == NSLeftMouseDragged)
        [_instance dragToPoint:[NSEvent mouseLocation]];
    else if ([event type] == NSMouseMoved)
        [_instance mouseOverAtPoint:[NSEvent mouseLocation]];
    else if ([event type] == NSMouseExited)
        [_instance mouseOutAtPoint:[NSEvent mouseLocation]];
    else
        [super sendEvent:event];
}


@end
