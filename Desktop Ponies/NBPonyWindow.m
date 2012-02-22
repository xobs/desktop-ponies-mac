//
//  NBPonyWindow.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyWindow.h"

@implementation NBPonyWindow

- (void)awakeFromNib
{
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    ponyView = [[NSImageView alloc] init];
    [ponyView setAnimates:YES];
    [ponyView setFrame:[self frameRectForContentRect:[self frame]]];
    [self setContentView:ponyView];
}

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
    ponyView = [[NSImageView alloc] init];
    [ponyView setAnimates:YES];
    [ponyView setFrame:[self frameRectForContentRect:[self frame]]];
    [self setContentView:ponyView];
    
    return self;
}

- (void)setPonyInstance:(NBPonyInstance *)instance
{
    if (_instance)
        [_instance release];
    _instance = [instance retain];
    [_instance setDelegate:self];

    NBPonyBehavior *behavior = [instance behavior];
    NSImage *left = [behavior leftImage];
    [ponyView setObjectValue:left];
}

- (void)behaviorTimeoutExpired:(NBPonyInstance *)instance
{
    [ponyView setObjectValue:[[instance startRandomBehavior] leftImage]];
}


@end
