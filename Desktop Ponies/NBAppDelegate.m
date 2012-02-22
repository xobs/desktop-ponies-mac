//
//  NBAppDelegate.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBAppDelegate.h"
#import "NBPonyInstance.h"

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
    

    NSArray *testPonies = [NSArray arrayWithObjects:@"Rainbow Dash", @"Pinkie Pie", @"Fluttershy",
                           @"Twilight Sparkle", @"Rarity", @"Applejack", @"Derpy Hooves", nil];
    
    windows = [[NSMutableArray alloc] init];
    for (NSString *name in testPonies) {
        NBPony *pony = [ponyCollection ponyNamed:name];
        if (!pony) {
            NSLog(@"Warning: No pony named %@", name);
            continue;
        }
        
        NBPonyWindow *tmp = [[NBPonyWindow alloc] initWithContentRect:NSMakeRect(100, 500, 50, 50)
                                                            styleMask:NSBorderlessWindowMask
                                                              backing:NSBackingStoreBuffered
                                                                defer:YES];
        [tmp setPonyInstance:[[NBPonyInstance alloc] initWithPony:pony]];
        [tmp makeKeyAndOrderFront:self];
        [windows addObject:tmp];
    }

    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.030
                                                 target:self
                                               selector:@selector(doTick:)
                                               userInfo:nil
                                                repeats:YES];
}

- (void)doTick:(id)sender
{
    for (NBPonyWindow *w in windows) {
        [w doTick];
    }
}

@end
