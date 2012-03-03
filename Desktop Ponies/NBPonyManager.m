//
//  NBPonyManager.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyManager.h"

@implementation NBPonyManager

- (NBPonyManager *)initWithPonyCollection:(NBPonyCollection *)collection
{
    if (!(self = [super init]))
        return nil;
    
    NSRect screenSize = [[NSScreen mainScreen] visibleFrame];

    _active = [[NSMutableArray alloc] init];
    _collection = [collection retain];
    
    
    // Allocate main interface window
    mainWindow = [[NSWindow alloc] initWithContentRect:screenSize styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
    [mainWindow setOpaque:NO];
    [mainWindow setBackgroundColor:[NSColor clearColor]];

    // Allocate the OpenGL view
    mainView = [[NBPonyGLView alloc] initWithFrame:[mainWindow contentRectForFrameRect:screenSize]];

    [mainWindow setContentView:mainView];
    [mainWindow makeKeyAndOrderFront:self];
    [mainView startup];

    return self;
}

- (BOOL)addPonyNamed:(NSString *)name
{
    NBPony *p = [_collection ponyNamed:name];
    NBPonyInstance *i;
    if (!p)
        return NO;
    
    i = [[NBPonyInstance alloc] initWithPony:p];
    if (!i)
        return NO;
    
    [mainView addPonyInstance:i];
    [i setDelegate:self];
    [i startRandomBehavior];

    [_active addObject:i];
    return YES;
}

- (NBPonyInstance *)ponyNamed:(NSString *)name
{
    for (NBPonyInstance *i in _active)
        if ([[[i pony] name] isEqualToString:name])
            return i;
    return nil;
}

- (BOOL)removePony:(NBPony *)pony
{
    int j = 0;
    for (NBPonyInstance *i in _active) {
        if ([i pony] == pony) {
            [_active removeObjectAtIndex:j];
            return YES;
        }
        j++;
    }
    return NO;
}

- (BOOL)removePonyNamed:(NSString *)name
{
    int j = 0;
    for (NBPonyInstance *i in _active) {
        if ([[[i pony] name] isEqualToString:name]) {
            [_active removeObjectAtIndex:j];
            return YES;
        }
        j++;
    }
    return NO;
}

- (int)tickAll:(long long)elapsed
{
    for (NBPonyInstance *i in _active)
        [i tick:elapsed];
    [mainView redraw];
    return 0;
}

- (void)addPonyInstance:(NBPonyInstance *)instance {
    [instance setDelegate:self];
}


#pragma mark -
#pragma mark Instance delegate methods

- (void)behaviorTimeoutExpiredForInstance:(NBPonyInstance *)instance
{
    [instance startRandomBehavior];
}
         
- (BOOL)wouldFitOnScreen:(NSSize)newSize forInstance:(NBPonyInstance *)instance
{
    NSRect screenSize = [[NSScreen mainScreen] visibleFrame];
    NSRect f = NSMakeRect([instance origin].x, [instance origin].y, newSize.width, newSize.height);
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
    NSRect f = NSMakeRect([instance origin].x, [instance origin].y, delta.width, delta.height);
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
    NSRect f = [mainView frame];
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
         
- (BOOL)behaviorIsAppropriate:(NBPonyBehavior *)behavior forInstance:(NBPonyInstance *)instance
{
    if ([behavior shouldSkip])
        return NO;
            
    if ([behavior movementFlags] >= 8)
        return NO;
            
    if (![self wouldFitOnScreen:[[behavior leftImage] size] forInstance:instance])
        return NO;
            
    return YES;
}
         

             
@end
