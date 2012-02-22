//
//  NBAppDelegate.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBAppDelegate.h"

@implementation NBAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ponyCollection = [[NBPonyCollection alloc] init];
    [ponyCollection loadPonies:@"/Users/smc/Downloads/Desktop Ponies V1.39"];
 
    NSLog(@"Pony collection: %@", ponyCollection);
    
    NBPony *fluttershy = [ponyCollection ponyNamed:@"Fluttershy"];
    NBPonyBehavior *behavior = [fluttershy behaviorNamed:@"walk"];
    NSImage *left = [behavior leftImage];
    [testOutput setObjectValue:left];
    
    testWindow = [[NBPonyWindow alloc] initWithContentRect:NSMakeRect(100, 100, 110, 110)
                                                 styleMask:NSBorderlessWindowMask
                                                   backing:NSBackingStoreBuffered
                                                     defer:YES];
    [testWindow setPony:[ponyCollection ponyNamed:@"Rainbow Dash"]];
    [testWindow makeKeyAndOrderFront:self];
}

@end
