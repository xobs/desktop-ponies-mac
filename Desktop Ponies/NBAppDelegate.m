//
//  NBAppDelegate.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <sys/time.h>
#import "NBAppDelegate.h"
#import "NBPonyInstance.h"

static long long getTimeMillis(void) {
    struct timeval time;
    gettimeofday(&time, NULL);
    return (time.tv_sec * 1000) + (time.tv_usec / 1000);
}



@implementation NBAppDelegate

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
                           @"Twilight Sparkle", @"Rarity", @"Applejack", @"Derpy Hooves", 
                           @"Vinyl Scratch",
                           @"80's Cheerilee",
                           @"Aloe",
                           @"Angel",
                           @"Apple Fritter",
                           @"Applejack",
                           @"Berry Punch (OPPP)",
                           @"Princess Celestia",
                           @"Big Mac",
                           @"Bon-Bon",
                           @"Candy Mane",
                           @"Caramel",
                           @"Cheerilee",
                           @"Colgate",
                           @"Derpy Hooves",
                           @"Doctor Whooves",
                           @"Filly Celestia (Pink)",
                           @"Filly Princess Luna",
                           @"Filly Rarity",
                           @"Filly Twilight Sparkle",
                           @"Fluttershy",
                           @"Gilda",
                           @"Gummy",
                           @"Lotus",
                           @"Lyra",
                           @"Mrs. Sparkle",
                           @"Nightmare Moon",
                           @"Octavia",
                           @"Opalescence",
                           @"Parasprite",
                           @"Pinkamina",
                           @"Pinkie Pie",
                           @"Filly Celestia",
                           @"Princess Luna",
                           @"Princess Luna (Season 2)",
                           @"Rainbow Dash",
                           @"Rarity",
                           @"Royal Guard",
                           @"Royal Night Guard",
                           @"Scootaloo",
                           @"Silver Spoon",
                           @"Soigne Folio",
                           @"Spike",
                           @"Spitfire",
                           @"Suitless Spitfire",
                           @"Stella",
                           @"Surprise",
                           @"Sweetie Belle",
                           @"Trixie",
                           @"Twilight Sparkle",
                           @"Winona",
                           @"Zecora",
                           nil];
    manager = [[NBPonyManager alloc] initWithPonyCollection:ponyCollection];
    [manager addPonyNamed:@"Pinkie Pie"];
    for (NSString *name in testPonies) {
        [manager addPonyNamed:name];
        [manager addPonyNamed:name];
        [manager addPonyNamed:name];
        [manager addPonyNamed:name];
        [manager addPonyNamed:name];
    }
    
    last = getTimeMillis();
    
    // start animation timer
	tickTimer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(doTick:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:tickTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:tickTimer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize
}

- (void)doTick:(id)sender
{
    long long this = getTimeMillis();
    long long diff = this-last;
    [manager tickAll:diff];
    last = this;
}

@end
