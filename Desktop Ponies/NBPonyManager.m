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
    
    [i showWindow];
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

- (int)tickAll
{
    for (NBPonyInstance *i in _active)
        [i tick];
    return 0;
}
             
@end
