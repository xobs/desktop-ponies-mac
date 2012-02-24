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
    
    // Add all these ponies to the manager
    NSArray *testPonies = [NSArray arrayWithObjects:@"Rainbow Dash", @"Pinkie Pie", @"Fluttershy",
                           @"Twilight Sparkle", @"Rarity", @"Applejack", @"Derpy Hooves", nil];
    manager = [[NBPonyManager alloc] initWithPonyCollection:ponyCollection];
    for (NSString *name in testPonies)
        [manager addPonyNamed:name];

    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.030
                                                 target:self
                                               selector:@selector(doTick:)
                                               userInfo:nil
                                                repeats:YES];
}

- (void)doTick:(id)sender
{
    [manager tickAll];
}

@end
