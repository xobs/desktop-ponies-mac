//
//  NBAppDelegate.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NBPonyCollection.h"
#import "NBPonyWindow.h"
#import "NBPonyManager.h"

@interface NBAppDelegate : NSObject <NSApplicationDelegate> {
    NBPonyCollection *ponyCollection;
    NBPonyManager *manager;
    NSTimer *tickTimer;
}

@property (assign) IBOutlet NSWindow *window;
- (void)doTick:(id)sender;

@end
