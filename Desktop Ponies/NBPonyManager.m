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
    mainWindow = [[NSWindow alloc] initWithContentRect:screenSize styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    [mainWindow setOpaque:NO];
    [mainWindow setBackgroundColor:[NSColor clearColor]];
    [mainWindow setLevel:NSMainMenuWindowLevel];
    [mainWindow setIgnoresMouseEvents:YES];

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
    if (!p)
        return NO;
    return [self addPony:p];
}
    
- (BOOL)addPony:(NBPony *)p
{
    NBPonyInstance *i;

    i = [[NBPonyInstance alloc] initWithPony:p];
    if (!i)
        return NO;
    
    [mainView addPonyInstance:i];
    [i setDelegate:self];
    [i startRandomBehavior];

    [_active addObject:i];
    return YES;
}

- (void)redraw {
    [mainView redraw];
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"NBPonyManager with %d active ponies", [_active count]];
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
    if ([[instance behavior] linkedBehavior] != nil) {
        [instance startBehavior:[[instance pony] behaviorNamed:[[instance behavior] linkedBehavior]]];
    }
    else {
        [instance startRandomBehavior];
    }
}
         

- (BOOL)wouldFitOnScreen:(NSRect)imageSize forInstance:(NBPonyInstance *)instance
{
    NSRect screenSize = [mainView frame];
    if (imageSize.origin.x < 0)
        return NO;
    if (imageSize.origin.y < 0)
        return NO;
    if (imageSize.origin.x + imageSize.size.width > screenSize.size.width + screenSize.origin.x)
        return NO;
    if (imageSize.origin.y + imageSize.size.height > screenSize.size.height + screenSize.origin.y)
        return NO;
    return YES;
}
         
- (NSSize)makeBestBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance
{
    NSRect screenSize = [mainView frame];
    NSRect f;
    
    f.size = [[instance image] size];
    f.origin = [instance origin];
            
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
    NSRect testRect;
    if ([behavior shouldSkip])
        return NO;
            
    if ([behavior movementFlags] >= 8)
        return NO;
    
    testRect.origin = [instance origin];
    testRect.size = [[instance image] size];
    if (![self wouldFitOnScreen:testRect forInstance:instance])
        return NO;
            
    return YES;
}
         

             
@end
